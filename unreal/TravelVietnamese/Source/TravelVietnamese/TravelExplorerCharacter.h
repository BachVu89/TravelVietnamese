#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "TravelExplorerCharacter.generated.h"

class USpringArmComponent;
class UCameraComponent;
class UStaticMeshComponent;

/** Grounded exploration source prototype. No motorcycle or complete mobile HUD port. */
UCLASS()
class TRAVELVIETNAMESE_API ATravelExplorerCharacter : public ACharacter
{
    GENERATED_BODY()
public:
    ATravelExplorerCharacter();
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Travel|Camera") TObjectPtr<USpringArmComponent> CameraBoom;
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="Travel|Camera") TObjectPtr<UCameraComponent> FollowCamera;
    UFUNCTION(BlueprintCallable, Category="Travel|Recovery") void SetSafeSpawnTransform(const FTransform& Transform);
    UFUNCTION(BlueprintCallable, Category="Travel|Recovery") void ResetToSafeSpawn();
    // Inspection trace only; no POI content, discovery stamp or persistence is implied.
    UFUNCTION(BlueprintCallable, Category="Travel|Interaction") void Interact();
private:
    void MoveForward(float Value);
    void MoveRight(float Value);
    void Turn(float Value);
    void LookUp(float Value);
    void TurnRate(float Value);
    void LookUpRate(float Value);
    bool CanAcceptPlayerInput() const;
    UPROPERTY() FTransform SafeSpawnTransform;
    UPROPERTY() bool bHasSafeSpawn = false;
    UPROPERTY() TArray<TObjectPtr<UStaticMeshComponent>> PlaceholderVisuals;
};
