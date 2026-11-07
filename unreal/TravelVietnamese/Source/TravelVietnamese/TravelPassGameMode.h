#pragma once
#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "TravelPassGameMode.generated.h"

/** Flying inspection pawn only. Motorcycle gameplay is intentionally not represented. */
UCLASS()
class TRAVELVIETNAMESE_API ATravelPassGameMode : public AGameModeBase
{
    GENERATED_BODY()
public:
    ATravelPassGameMode();
    virtual void StartPlay() override;
};
