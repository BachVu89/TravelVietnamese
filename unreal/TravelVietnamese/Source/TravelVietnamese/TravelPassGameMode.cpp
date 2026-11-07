#include "TravelPassGameMode.h"
#include "TravelExplorerCharacter.h"
#include "TravelPassEnvironment.h"
#include "Components/CapsuleComponent.h"
#include "Components/SplineComponent.h"
#include "Engine/World.h"
#include "EngineUtils.h"
#include "GameFramework/PlayerController.h"
#include "GameFramework/CharacterMovementComponent.h"

ATravelPassGameMode::ATravelPassGameMode()
{
    DefaultPawnClass = ATravelExplorerCharacter::StaticClass();
}

void ATravelPassGameMode::StartPlay()
{
    bool bEnvironmentExists = false;
    for (TActorIterator<ATravelPassEnvironment> It(GetWorld()); It; ++It)
    {
        bEnvironmentExists = true;
        break;
    }
    if (!bEnvironmentExists) GetWorld()->SpawnActor<ATravelPassEnvironment>(FVector::ZeroVector,FRotator::ZeroRotator);
    Super::StartPlay();
    PlaceAtRouteStart(GetWorld()->GetFirstPlayerController());
}

void ATravelPassGameMode::RestartPlayer(AController* NewPlayer)
{
    Super::RestartPlayer(NewPlayer);
    PlaceAtRouteStart(NewPlayer);
}

void ATravelPassGameMode::PlaceAtRouteStart(AController* Player)
{
    if (!Player) return;
    ATravelExplorerCharacter* Character = Cast<ATravelExplorerCharacter>(Player->GetPawn());
    if (!Character) return;
    for (TActorIterator<ATravelPassEnvironment> It(GetWorld()); It; ++It)
    {
        const ATravelPassEnvironment* Environment = *It;
        const FVector Local = Environment->RoutePosition(500.0f,0.0f);
        FVector World = Environment->GetActorTransform().TransformPosition(Local);
        World.Z += Character->GetCapsuleComponent()->GetScaledCapsuleHalfHeight()+20.0f;
        const FVector Direction = Environment->GetActorTransform().TransformVectorNoScale(
            Environment->Route->GetDirectionAtDistanceAlongSpline(500.0f,ESplineCoordinateSpace::Local));
        const FRotator Facing(0,Direction.Rotation().Yaw,0);
        const FTransform Spawn(Facing,World);
        Character->SetSafeSpawnTransform(Spawn);
        Character->GetCharacterMovement()->StopMovementImmediately();
        Character->SetActorLocationAndRotation(World,Facing,false,nullptr,ETeleportType::TeleportPhysics);
        Player->SetControlRotation(FRotator(-12,Facing.Yaw,0));
        break;
    }
}
