#pragma once
#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "TravelPassGameMode.generated.h"

/** Grounded exploration source proof; motorcycle and full mobile HUD remain unported. */
UCLASS()
class TRAVELVIETNAMESE_API ATravelPassGameMode : public AGameModeBase
{
    GENERATED_BODY()
public:
    ATravelPassGameMode();
    virtual void StartPlay() override;
    virtual void RestartPlayer(AController* NewPlayer) override;
private:
    void PlaceAtRouteStart(AController* Player);
};
