#include "TravelPassGameMode.h"
#include "TravelPassEnvironment.h"
#include "GameFramework/DefaultPawn.h"
#include "GameFramework/PlayerController.h"
#include "Engine/World.h"
#include "EngineUtils.h"

ATravelPassGameMode::ATravelPassGameMode()
{
    DefaultPawnClass = ADefaultPawn::StaticClass();
}

void ATravelPassGameMode::StartPlay()
{
    Super::StartPlay();
    bool bEnvironmentExists = false;
    for (TActorIterator<ATravelPassEnvironment> It(GetWorld()); It; ++It)
    {
        bEnvironmentExists = true;
        break;
    }
    if (!bEnvironmentExists)
    {
        GetWorld()->SpawnActor<ATravelPassEnvironment>(FVector::ZeroVector, FRotator::ZeroRotator);
    }
    if (APlayerController* Controller = GetWorld()->GetFirstPlayerController())
    {
        if (APawn* Pawn = Controller->GetPawn())
        {
            Pawn->SetActorLocation(FVector(-1000, 0, 1200));
            Controller->SetControlRotation(FRotator(-12, 15, 0));
        }
    }
}
