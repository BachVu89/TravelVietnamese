#include "TravelPassEnvironment.h"
#include "Components/SceneComponent.h"
#include "Components/SplineComponent.h"
#include "Components/HierarchicalInstancedStaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "Materials/MaterialInterface.h"
#include "ProceduralMeshComponent.h"
#include "UObject/ConstructorHelpers.h"

ATravelPassEnvironment::ATravelPassEnvironment()
{
    PrimaryActorTick.bCanEverTick = false;
    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("Root"));
    SetRootComponent(SceneRoot);
    Route = CreateDefaultSubobject<USplineComponent>(TEXT("Route"));
    Route->SetupAttachment(SceneRoot);
    Surface = CreateDefaultSubobject<UProceduralMeshComponent>(TEXT("RoadAndTerrain"));
    Surface->SetupAttachment(SceneRoot);
    // Bounded proof mesh: finish floor collision before the grounded pawn is spawned.
    // Revisit startup cost and baked collision when profiling production maps.
    Surface->bUseAsyncCooking = false;
    Surface->bUseComplexAsSimpleCollision = true;
    Surface->SetCollisionProfileName(TEXT("BlockAll"));
    Guardrails = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Guardrails"));
    TreeTrunks = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("TreeTrunks"));
    TreeCrowns = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("TreeCrowns"));
    for (auto* Component : {Guardrails.Get(), TreeTrunks.Get(), TreeCrowns.Get()})
    {
        Component->SetupAttachment(SceneRoot);
        Component->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        Component->SetCullDistances(0, 45000);
    }
    RockOutcrops = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("OriginalRockOutcrops"));
    FernPlants = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("OriginalFerns"));
    BananaPlants = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("OriginalBananas"));
    for (auto* Component : {RockOutcrops.Get(), FernPlants.Get(), BananaPlants.Get()})
    {
        Component->SetupAttachment(SceneRoot);
        Component->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        Component->SetCullDistances(0, 22000);
    }
    Guardrails->SetCollisionProfileName(TEXT("BlockAll"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Cube(TEXT("/Engine/BasicShapes/Cube.Cube"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Cylinder(TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Sphere(TEXT("/Engine/BasicShapes/Sphere.Sphere"));
    if (Cube.Succeeded()) Guardrails->SetStaticMesh(Cube.Object);
    if (Cylinder.Succeeded()) TreeTrunks->SetStaticMesh(Cylinder.Object);
    if (Sphere.Succeeded()) TreeCrowns->SetStaticMesh(Sphere.Object);
}

void ATravelPassEnvironment::OnConstruction(const FTransform& Transform)
{
    Super::OnConstruction(Transform);
    Regenerate();
}

void ATravelPassEnvironment::BuildSpline()
{
    Route->ClearSplinePoints(false);
    for (int32 Index = 0; Index <= 20; ++Index)
    {
        const float S = Index * 3750.0f;
        Route->AddSplinePoint(FVector(S, 2600.0f * FMath::Sin(S / 8500.0f) + 1000.0f * FMath::Sin(S / 3700.0f),
            400.0f + S * 0.065f + 300.0f * FMath::Sin(S / 10000.0f)), ESplineCoordinateSpace::Local, false);
        Route->SetSplinePointType(Index, ESplinePointType::CurveClamped, false);
    }
    Route->UpdateSpline();
}

float ATravelPassEnvironment::RouteLengthCm() const { return Route->GetSplineLength(); }

FVector ATravelPassEnvironment::RoutePosition(float DistanceCm, float LateralCm) const
{
    const float S = FMath::Clamp(DistanceCm, 0.0f, RouteLengthCm());
    const FVector Center = Route->GetLocationAtDistanceAlongSpline(S, ESplineCoordinateSpace::Local);
    const FVector Forward = Route->GetDirectionAtDistanceAlongSpline(S, ESplineCoordinateSpace::Local);
    const FVector Right = FVector::CrossProduct(FVector::UpVector, Forward).GetSafeNormal();
    return Center + Right * LateralCm;
}

float ATravelPassEnvironment::OuterEdge(float S) const
{
    const float Length = RouteLengthCm();
    return FMath::Abs(S - Length * 0.31f) < 2100.0f || FMath::Abs(S - Length * 0.73f) < 2100.0f ? 1300.0f : 425.0f;
}

void ATravelPassEnvironment::BuildStrip(int32 Section, float Left, float Right, UMaterialInterface* Material, bool bCliff, bool bValley, float StartCm, float EndCm)
{
    TArray<FVector> Vertices, Normals;
    TArray<int32> Triangles;
    TArray<FVector2D> UVs;
    const float Start = FMath::Clamp(StartCm, 0.0f, RouteLengthCm());
    const float End = EndCm < 0 ? RouteLengthCm() : FMath::Clamp(EndCm, Start, RouteLengthCm());
    const int32 Count = FMath::Clamp(FMath::CeilToInt(FMath::Clamp(RoadSegments, 64, 512) * (End-Start) / FMath::Max(1.0f,RouteLengthCm())), 8, 512);
    for (int32 Index = 0; Index <= Count; ++Index)
    {
        const float S = FMath::Lerp(Start, End, static_cast<float>(Index) / Count);
        for (int32 Edge = 0; Edge < 2; ++Edge)
        {
            const float Offset = Edge == 0 ? Left : Right;
            FVector P = RoutePosition(S, Offset);
            if (bCliff) P.Z += FMath::Max(0.0f, -Offset - 425.0f) * (0.72f + 0.08f * FMath::Sin(S * 0.0007f));
            if (bValley) P.Z -= FMath::Max(0.0f, Offset - 425.0f) * 0.55f;
            Vertices.Add(P);
            UVs.Add(FVector2D(S / 500.0f, Offset / 500.0f));
            Normals.Add(FVector::UpVector);
        }
    }
    for (int32 Index = 0; Index < Count; ++Index)
    {
        const int32 A = Index * 2;
        Triangles.Append({A, A + 2, A + 1, A + 1, A + 2, A + 3});
    }
    // Compute geometric normals for slopes. UV and vertices use centimetres / 5m tiles.
    for (FVector& Normal : Normals) Normal = FVector::ZeroVector;
    for (int32 Index = 0; Index < Triangles.Num(); Index += 3)
    {
        const int32 A = Triangles[Index], B = Triangles[Index + 1], C = Triangles[Index + 2];
        const FVector N = FVector::CrossProduct(Vertices[B] - Vertices[A], Vertices[C] - Vertices[A]).GetSafeNormal();
        Normals[A] += N; Normals[B] += N; Normals[C] += N;
    }
    for (FVector& Normal : Normals) Normal.Normalize();
    Surface->CreateMeshSection_LinearColor(Section, Vertices, Triangles, Normals, UVs,
        TArray<FLinearColor>(), TArray<FProcMeshTangent>(), Section <= 2 || Section >= 6);
    if (Material) Surface->SetMaterial(Section, Material);
}

void ATravelPassEnvironment::BuildMarkings()
{
    TArray<FVector> Vertices, Normals;
    TArray<int32> Triangles;
    TArray<FVector2D> UVs;
    for (float S = 200.0f; S + 350.0f < RouteLengthCm(); S += 700.0f)
    {
        const int32 A = Vertices.Num();
        for (const FVector2D Spec : {FVector2D(S, -6), FVector2D(S + 350, -6), FVector2D(S, 6), FVector2D(S + 350, 6)})
        {
            Vertices.Add(RoutePosition(Spec.X, Spec.Y) + FVector(0, 0, 3));
            Normals.Add(FVector::UpVector);
            UVs.Add(FVector2D(Spec.X / 100.0f, Spec.Y / 100.0f));
        }
        Triangles.Append({A, A + 1, A + 2, A + 2, A + 1, A + 3});
    }
    Surface->CreateMeshSection_LinearColor(5, Vertices, Triangles, Normals, UVs,
        TArray<FLinearColor>(), TArray<FProcMeshTangent>(), false);
    if (MarkingMaterial) Surface->SetMaterial(5, MarkingMaterial);
}

void ATravelPassEnvironment::BuildInstances()
{
    Guardrails->ClearInstances(); TreeTrunks->ClearInstances(); TreeCrowns->ClearInstances();
    for (float S = 0; S + 500 < RouteLengthCm(); S += 500)
    {
        for (const float Side : {-1.0f, 1.0f})
        {
            const float Offset = Side < 0 ? -425.0f : OuterEdge(S);
            const FVector A = RoutePosition(S, Offset), B = RoutePosition(S + 500, Offset);
            const FRotator Rotation = (B - A).Rotation();
            Guardrails->AddInstance(FTransform(Rotation, (A + B) * 0.5f + FVector(0, 0, 78), FVector((B-A).Size()/100.0f, 0.14f, 0.36f)));
        }
    }
    FRandomStream Random(GenerationSeed);
    for (int32 Index = 0; Index < FMath::Clamp(TreeCount, 0, 1500); ++Index)
    {
        const float S = Random.FRandRange(0, RouteLengthCm());
        const float Side = Index % 2 == 0 ? -1.0f : 1.0f;
        const float Offset = Side * Random.FRandRange(Side < 0 ? 800.0f : 1800.0f, 6500.0f);
        FVector P = RoutePosition(S, Offset);
        P.Z += Side < 0 ? (-Offset - 425) * (0.72f + 0.08f * FMath::Sin(S * 0.0007f)) : -(Offset - 425) * 0.55f;
        TreeTrunks->AddInstance(FTransform(FRotator::ZeroRotator, P + FVector(0,0,250), FVector(0.32,0.32,5.0)));
        const float Size = Random.FRandRange(3.5f,6.5f);
        TreeCrowns->AddInstance(FTransform(FRotator::ZeroRotator, P + FVector(0,0,550), FVector(Size, Size, Size*1.25f)));
    }
    if (MetalMaterial) Guardrails->SetMaterial(0, MetalMaterial);
    if (TrunkMaterial) TreeTrunks->SetMaterial(0, TrunkMaterial);
    if (FoliageMaterial) TreeCrowns->SetMaterial(0, FoliageMaterial);
}

FVector ATravelPassEnvironment::TerrainPosition(float S, float Offset) const
{
    FVector P = RoutePosition(S, Offset);
    if (Offset < -425.0f)
        P.Z += (-Offset - 425.0f) * (0.72f + 0.08f * FMath::Sin(S * 0.0007f));
    else if (Offset > 425.0f)
        P.Z -= (Offset - 425.0f) * 0.55f;
    return P;
}

void ATravelPassEnvironment::BuildOriginalArt()
{
    RockOutcrops->ClearInstances(); FernPlants->ClearInstances(); BananaPlants->ClearInstances();
    RockOutcrops->SetStaticMesh(RockOutcropMesh.Get());
    FernPlants->SetStaticMesh(FernMesh.Get());
    BananaPlants->SetStaticMesh(BananaMesh.Get());
    // Separate seed: adding understory never changes baseline trees, collisions or the route.
    FRandomStream Random(GenerationSeed ^ 0x51A7);
    if (RockOutcropMesh)
    {
        for (int32 Index = 0; Index < 72; ++Index)
        {
            const float S = Random.FRandRange(500.0f, RouteLengthCm()-500.0f);
            const float Offset = -Random.FRandRange(850.0f, 2200.0f);
            const float Scale = Random.FRandRange(0.65f, 1.8f);
            RockOutcrops->AddInstance(FTransform(FRotator(0, Random.FRandRange(0,360), 0),
                TerrainPosition(S, Offset) - FVector(0,0,20), FVector(Scale)));
        }
    }
    for (int32 Index = 0; Index < FMath::Clamp(UnderstoryCount, 0, 500); ++Index)
    {
        const float S = Random.FRandRange(500.0f, RouteLengthCm()-500.0f);
        const float Offset = Index % 2 == 0 ? -Random.FRandRange(600.0f, 1700.0f)
            : Random.FRandRange(FMath::Max(1500.0f, OuterEdge(S)+200.0f), 3200.0f);
        const float Yaw = Random.FRandRange(0,360);
        const float Scale = Random.FRandRange(0.7f,1.3f);
        const FTransform Placement(FRotator(0,Yaw,0), TerrainPosition(S, Offset), FVector(Scale));
        if (Index % 4 == 0 && BananaMesh) BananaPlants->AddInstance(Placement);
        else if (FernMesh) FernPlants->AddInstance(Placement);
    }
}

void ATravelPassEnvironment::Regenerate()
{
    BuildSpline();
    Surface->ClearAllMeshSections();
    BuildStrip(0, -350, 350, RoadMaterial, false, false);
    BuildStrip(1, -425, -350, ShoulderMaterial, false, false);
    BuildStrip(2, 350, 425, ShoulderMaterial, false, false);
    BuildStrip(3, -7500, -425, RockMaterial, true, false);
    BuildStrip(4, 425, 11000, FoliageMaterial, false, true);
    BuildStrip(6, 425, 1300, ShoulderMaterial, false, false, RouteLengthCm()*0.31f-2100, RouteLengthCm()*0.31f+2100);
    BuildStrip(7, 425, 1300, ShoulderMaterial, false, false, RouteLengthCm()*0.73f-2100, RouteLengthCm()*0.73f+2100);
    BuildMarkings();
    BuildInstances();
    BuildOriginalArt();
}
