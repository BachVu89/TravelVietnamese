#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "TravelPassEnvironment.generated.h"

class USceneComponent;
class USplineComponent;
class UProceduralMeshComponent;
class UHierarchicalInstancedStaticMeshComponent;
class UMaterialInterface;

/** Original procedural environment proof. Unreal units are centimetres, not GIS metres.
 * No downloaded scans, PCG graph, vehicle simulation or photoreal assets are included. */
UCLASS()
class TRAVELVIETNAMESE_API ATravelPassEnvironment : public AActor
{
    GENERATED_BODY()
public:
    ATravelPassEnvironment();
    virtual void OnConstruction(const FTransform& Transform) override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Pass") TObjectPtr<USplineComponent> Route;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Pass") TObjectPtr<UProceduralMeshComponent> Surface;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Pass") TObjectPtr<UHierarchicalInstancedStaticMeshComponent> Guardrails;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Pass") TObjectPtr<UHierarchicalInstancedStaticMeshComponent> TreeTrunks;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Pass") TObjectPtr<UHierarchicalInstancedStaticMeshComponent> TreeCrowns;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Generation", meta=(ClampMin="64", ClampMax="512")) int32 RoadSegments = 192;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Generation", meta=(ClampMin="0", ClampMax="1500")) int32 TreeCount = 420;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Generation") int32 GenerationSeed = 41004;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> RoadMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> ShoulderMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> RockMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> FoliageMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> TrunkMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> MarkingMaterial;
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pass|Materials") TObjectPtr<UMaterialInterface> MetalMaterial;

    UFUNCTION(CallInEditor, BlueprintCallable, Category="Pass") void Regenerate();
    UFUNCTION(BlueprintPure, Category="Pass") FVector RoutePosition(float DistanceCm, float LateralCm = 0.0f) const;
    UFUNCTION(BlueprintPure, Category="Pass") float RouteLengthCm() const;

private:
    UPROPERTY() TObjectPtr<USceneComponent> SceneRoot;
    void BuildSpline();
    void BuildStrip(int32 Section, float LeftCm, float RightCm, UMaterialInterface* Material, bool bCliff, bool bValley, float StartCm = 0.0f, float EndCm = -1.0f);
    void BuildMarkings();
    void BuildInstances();
    float OuterEdge(float DistanceCm) const;
};
