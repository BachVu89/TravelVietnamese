#include "TravelExplorerCharacter.h"
#include "Camera/CameraComponent.h"
#include "CollisionQueryParams.h"
#include "Engine/EngineTypes.h"
#include "Components/CapsuleComponent.h"
#include "Components/InputComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/Engine.h"
#include "Engine/StaticMesh.h"
#include "Engine/World.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/PlayerController.h"
#include "GameFramework/SpringArmComponent.h"
#include "UObject/ConstructorHelpers.h"

ATravelExplorerCharacter::ATravelExplorerCharacter()
{
    PrimaryActorTick.bCanEverTick = false;
    GetCapsuleComponent()->InitCapsuleSize(34.0f, 96.0f);
    bUseControllerRotationPitch = false;
    bUseControllerRotationYaw = false;
    bUseControllerRotationRoll = false;
    GetCharacterMovement()->bOrientRotationToMovement = true;
    GetCharacterMovement()->RotationRate = FRotator(0, 540, 0);
    GetCharacterMovement()->MaxWalkSpeed = 450.0f;
    GetCharacterMovement()->JumpZVelocity = 420.0f;
    GetCharacterMovement()->AirControl = 0.15f;
    GetCharacterMovement()->MaxStepHeight = 35.0f;
    CameraBoom = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraBoom"));
    CameraBoom->SetupAttachment(GetRootComponent());
    CameraBoom->TargetArmLength = 480.0f;
    CameraBoom->SocketOffset = FVector(0, 45, 70);
    CameraBoom->bUsePawnControlRotation = true;
    CameraBoom->bDoCollisionTest = true;
    FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
    FollowCamera->SetupAttachment(CameraBoom, USpringArmComponent::SocketName);
    FollowCamera->bUsePawnControlRotation = false;
    FollowCamera->FieldOfView = 70.0f;

    // Engine primitives: original placeholder silhouette, not a licensed human scan.
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Cylinder(TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> Sphere(TEXT("/Engine/BasicShapes/Sphere.Sphere"));
    const auto AddVisual = [this](const TCHAR* Name, UStaticMesh* Mesh, FVector Location, FVector Scale)
    {
        UStaticMeshComponent* Visual = CreateDefaultSubobject<UStaticMeshComponent>(Name);
        Visual->SetupAttachment(GetRootComponent());
        Visual->SetStaticMesh(Mesh);
        Visual->SetRelativeLocation(Location);
        Visual->SetRelativeScale3D(Scale);
        Visual->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        PlaceholderVisuals.Add(Visual);
    };
    if (Cylinder.Succeeded())
    {
        AddVisual(TEXT("Torso"), Cylinder.Object, FVector(0,0,-8), FVector(0.45,0.45,1.0));
        AddVisual(TEXT("LeftLeg"), Cylinder.Object, FVector(0,-12,-64), FVector(0.16,0.16,0.6));
        AddVisual(TEXT("RightLeg"), Cylinder.Object, FVector(0,12,-64), FVector(0.16,0.16,0.6));
        AddVisual(TEXT("LeftArm"), Cylinder.Object, FVector(0,-32,1), FVector(0.12,0.12,0.65));
        AddVisual(TEXT("RightArm"), Cylinder.Object, FVector(0,32,1), FVector(0.12,0.12,0.65));
    }
    if (Sphere.Succeeded()) AddVisual(TEXT("Head"), Sphere.Object, FVector(0,0,66), FVector(0.4));
}

bool ATravelExplorerCharacter::CanAcceptPlayerInput() const
{
    const APlayerController* PC = Cast<APlayerController>(GetController());
    return PC && IsLocallyControlled() && GetWorld() && !GetWorld()->IsPaused();
}

void ATravelExplorerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);
    PlayerInputComponent->BindAxis(TEXT("MoveForward"), this, &ATravelExplorerCharacter::MoveForward);
    PlayerInputComponent->BindAxis(TEXT("MoveRight"), this, &ATravelExplorerCharacter::MoveRight);
    PlayerInputComponent->BindAxis(TEXT("Turn"), this, &ATravelExplorerCharacter::Turn);
    PlayerInputComponent->BindAxis(TEXT("LookUp"), this, &ATravelExplorerCharacter::LookUp);
    PlayerInputComponent->BindAxis(TEXT("TurnRate"), this, &ATravelExplorerCharacter::TurnRate);
    PlayerInputComponent->BindAxis(TEXT("LookUpRate"), this, &ATravelExplorerCharacter::LookUpRate);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Pressed, this, &ACharacter::Jump);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Released, this, &ACharacter::StopJumping);
    PlayerInputComponent->BindAction(TEXT("Interact"), IE_Pressed, this, &ATravelExplorerCharacter::Interact);
    PlayerInputComponent->BindAction(TEXT("ResetToRoute"), IE_Pressed, this, &ATravelExplorerCharacter::ResetToSafeSpawn);
}

void ATravelExplorerCharacter::MoveForward(float Value)
{
    if (CanAcceptPlayerInput() && !GetController()->IsMoveInputIgnored() && FMath::IsFinite(Value))
        AddMovementInput(FRotationMatrix(FRotator(0,GetControlRotation().Yaw,0)).GetUnitAxis(EAxis::X), FMath::Clamp(Value,-1.0f,1.0f));
}
void ATravelExplorerCharacter::MoveRight(float Value)
{
    if (CanAcceptPlayerInput() && !GetController()->IsMoveInputIgnored() && FMath::IsFinite(Value))
        AddMovementInput(FRotationMatrix(FRotator(0,GetControlRotation().Yaw,0)).GetUnitAxis(EAxis::Y), FMath::Clamp(Value,-1.0f,1.0f));
}
void ATravelExplorerCharacter::Turn(float Value)
{
    if (CanAcceptPlayerInput() && FMath::IsFinite(Value)) AddControllerYawInput(Value);
}
void ATravelExplorerCharacter::LookUp(float Value)
{
    if (CanAcceptPlayerInput() && FMath::IsFinite(Value)) AddControllerPitchInput(Value);
}
void ATravelExplorerCharacter::TurnRate(float Value)
{
    if (GetWorld()) Turn(FMath::Clamp(Value,-1.0f,1.0f) * 75.0f * GetWorld()->GetDeltaSeconds());
}
void ATravelExplorerCharacter::LookUpRate(float Value)
{
    if (GetWorld()) LookUp(FMath::Clamp(Value,-1.0f,1.0f) * 65.0f * GetWorld()->GetDeltaSeconds());
}

void ATravelExplorerCharacter::SetSafeSpawnTransform(const FTransform& Transform)
{
    if (Transform.ContainsNaN()) return;
    SafeSpawnTransform = FTransform(Transform.GetRotation(),Transform.GetLocation(),FVector::OneVector);
    bHasSafeSpawn = true;
}

void ATravelExplorerCharacter::ResetToSafeSpawn()
{
    if (!bHasSafeSpawn || !CanAcceptPlayerInput()) return;
    FCollisionQueryParams Params(SCENE_QUERY_STAT(TravelResetOccupancy),false,this);
    const bool bOccupied = GetWorld()->OverlapBlockingTestByChannel(
        SafeSpawnTransform.GetLocation(),SafeSpawnTransform.GetRotation(),ECC_Pawn,
        GetCapsuleComponent()->GetCollisionShape(),Params);
    if (bOccupied)
    {
        if (GEngine) GEngine->AddOnScreenDebugMessage(-1,3.0f,FColor::Yellow,TEXT("Route start is occupied; reset cancelled."));
        return;
    }
    GetCharacterMovement()->StopMovementImmediately();
    ConsumeMovementInputVector();
    SetActorLocationAndRotation(SafeSpawnTransform.GetLocation(),SafeSpawnTransform.GetRotation(),false,nullptr,ETeleportType::TeleportPhysics);
    GetCharacterMovement()->SetMovementMode(MOVE_Walking);
    if (Controller) Controller->SetControlRotation(FRotator(-12,SafeSpawnTransform.Rotator().Yaw,0));
}

void ATravelExplorerCharacter::Interact()
{
    if (!CanAcceptPlayerInput()) return;
    FHitResult Hit;
    FCollisionQueryParams Params(SCENE_QUERY_STAT(TravelInspect),false,this);
    const FVector Start = FollowCamera->GetComponentLocation();
    const FVector End = Start + FollowCamera->GetForwardVector()*1200.0f;
    const bool bHit = GetWorld()->LineTraceSingleByChannel(Hit,Start,End,ECC_Visibility,Params);
    if (GEngine)
    {
        const FString Message = bHit && Hit.GetActor() ? FString::Printf(TEXT("Inspection: %s (source prototype)"),*Hit.GetActor()->GetName())
                                                     : TEXT("Nothing nearby to inspect (source prototype)");
        GEngine->AddOnScreenDebugMessage(-1,3.0f,FColor::Cyan,Message);
    }
}
