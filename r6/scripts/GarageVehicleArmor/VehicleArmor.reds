// Garage Vehicle Armor
// Armor plating for the player's vehicles, bought per vehicle through Garage.
// A fitted tier cuts the damage that vehicle takes, and the damage V takes inside it.
module GarageVehicleArmor

// Player-facing options. With the Mod Settings mod installed they appear in its
// in-game menu; without it the defaults below apply.
public class ArmorSettings {
  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Damage reduction")
  @runtimeProperty("ModSettings.displayName", "Light armor (%)")
  @runtimeProperty("ModSettings.description", "How much less damage a vehicle with light armor takes.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "5")
  public let lightReduction: Int32 = 15;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Damage reduction")
  @runtimeProperty("ModSettings.displayName", "Medium armor (%)")
  @runtimeProperty("ModSettings.description", "How much less damage a vehicle with medium armor takes.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "5")
  public let mediumReduction: Int32 = 30;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Damage reduction")
  @runtimeProperty("ModSettings.displayName", "Heavy armor (%)")
  @runtimeProperty("ModSettings.description", "How much less damage a vehicle with heavy armor takes.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "5")
  public let heavyReduction: Int32 = 50;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Occupants")
  @runtimeProperty("ModSettings.displayName", "Armor protects V")
  @runtimeProperty("ModSettings.description", "While V is inside an armored car, damage to V is cut by the same amount as damage to the car.")
  public let protectOccupants: Bool = true;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Weight")
  @runtimeProperty("ModSettings.displayName", "Light armor acceleration loss (%)")
  @runtimeProperty("ModSettings.description", "How much slower a car with light armor gains speed. 0 turns the penalty off.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "1")
  public let lightWeight: Int32 = 10;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Weight")
  @runtimeProperty("ModSettings.displayName", "Medium armor acceleration loss (%)")
  @runtimeProperty("ModSettings.description", "How much slower a car with medium armor gains speed. 0 turns the penalty off.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "1")
  public let mediumWeight: Int32 = 15;

  @runtimeProperty("ModSettings.mod", "Garage Vehicle Armor")
  @runtimeProperty("ModSettings.category", "Weight")
  @runtimeProperty("ModSettings.displayName", "Heavy armor acceleration loss (%)")
  @runtimeProperty("ModSettings.description", "How much slower a car with heavy armor gains speed. 0 turns the penalty off.")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "95")
  @runtimeProperty("ModSettings.step", "1")
  public let heavyWeight: Int32 = 20;

  // Acceleration loss for a tier, as a percentage.
  public func WeightPercent(tier: ArmorTier) -> Int32 {
    switch tier {
      case ArmorTier.Light:
        return this.lightWeight;
      case ArmorTier.Medium:
        return this.mediumWeight;
      case ArmorTier.Heavy:
        return this.heavyWeight;
    }
    return 0;
  }

  public static func Get() -> ref<ArmorSettings> {
    let system: ref<ArmorSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"GarageVehicleArmor.ArmorSystem") as ArmorSystem;
    if IsDefined(system) {
      return system.GetSettings();
    }
    return new ArmorSettings();
  }

  // Damage reduction for a tier, as a percentage.
  public func ReductionPercent(tier: ArmorTier) -> Int32 {
    switch tier {
      case ArmorTier.Light:
        return this.lightReduction;
      case ArmorTier.Medium:
        return this.mediumReduction;
      case ArmorTier.Heavy:
        return this.heavyReduction;
    }
    return 0;
  }
}

// Owns the settings for the session and keeps them in step with the Mod Settings menu.
public class ArmorSystem extends ScriptableSystem {
  private let m_settings: ref<ArmorSettings>;

  private func OnAttach() -> Void {
    this.GetSettings();
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_settings) {
      Armor_UnregisterSettings(this.m_settings);
    }
  }

  public func GetSettings() -> ref<ArmorSettings> {
    if !IsDefined(this.m_settings) {
      this.m_settings = new ArmorSettings();
      Armor_RegisterSettings(this.m_settings);
    }
    return this.m_settings;
  }
}

@if(ModuleExists("ModSettingsModule"))
func Armor_RegisterSettings(settings: ref<ArmorSettings>) -> Void {
  ModSettings.RegisterListenerToClass(settings);
}

@if(!ModuleExists("ModSettingsModule"))
func Armor_RegisterSettings(settings: ref<ArmorSettings>) -> Void {}

@if(ModuleExists("ModSettingsModule"))
func Armor_UnregisterSettings(settings: ref<ArmorSettings>) -> Void {
  ModSettings.UnregisterListenerToClass(settings);
}

@if(!ModuleExists("ModSettingsModule"))
func Armor_UnregisterSettings(settings: ref<ArmorSettings>) -> Void {}

public enum ArmorTier {
  None = 0,
  Light = 1,
  Medium = 2,
  Heavy = 3
}

public class ArmorInstallEntry {
  public persistent let vehicleRecord: TweakDBID;
  // The fitted tier, as an ArmorTier value. A vehicle carries one tier at a time.
  public persistent let installedTier: Int32;
  public persistent let lightOwned: Bool;
  public persistent let mediumOwned: Bool;
  public persistent let heavyOwned: Bool;
}

// Which armor each of the player's vehicles has, saved with the game.
public class ArmorInstallSystem extends ScriptableSystem {
  private persistent let m_entries: array<ref<ArmorInstallEntry>>;

  public static func Get(game: GameInstance) -> ref<ArmorInstallSystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"GarageVehicleArmor.ArmorInstallSystem") as ArmorInstallSystem;
  }

  private func Find(record: TweakDBID, create: Bool) -> ref<ArmorInstallEntry> {
    let entry: ref<ArmorInstallEntry>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_entries) {
      if this.m_entries[i].vehicleRecord == record {
        return this.m_entries[i];
      }
      i += 1;
    }
    if !create {
      return null;
    }
    entry = new ArmorInstallEntry();
    entry.vehicleRecord = record;
    ArrayPush(this.m_entries, entry);
    return entry;
  }

  public func GetInstalled(record: TweakDBID) -> ArmorTier {
    let entry: ref<ArmorInstallEntry> = this.Find(record, false);
    if !IsDefined(entry) {
      return ArmorTier.None;
    }
    return IntEnum<ArmorTier>(entry.installedTier);
  }

  // True once the tier has been bought for this vehicle, fitted or not.
  public func IsOwned(record: TweakDBID, tier: ArmorTier) -> Bool {
    let entry: ref<ArmorInstallEntry> = this.Find(record, false);
    if !IsDefined(entry) {
      return false;
    }
    switch tier {
      case ArmorTier.Light:
        return entry.lightOwned;
      case ArmorTier.Medium:
        return entry.mediumOwned;
      case ArmorTier.Heavy:
        return entry.heavyOwned;
    }
    return false;
  }

  // Fits the tier, replacing whatever was fitted. The replaced tier stays owned.
  public func Install(record: TweakDBID, tier: ArmorTier) -> Bool {
    let entry: ref<ArmorInstallEntry>;
    if Equals(tier, ArmorTier.None) {
      return false;
    }
    entry = this.Find(record, true);
    if entry.installedTier == EnumInt(tier) {
      return false;
    }
    entry.installedTier = EnumInt(tier);
    switch tier {
      case ArmorTier.Light:
        entry.lightOwned = true;
        break;
      case ArmorTier.Medium:
        entry.mediumOwned = true;
        break;
      case ArmorTier.Heavy:
        entry.heavyOwned = true;
        break;
    }
    return true;
  }

  public func Remove(record: TweakDBID) -> Bool {
    let entry: ref<ArmorInstallEntry> = this.Find(record, false);
    if !IsDefined(entry) || entry.installedTier == 0 {
      return false;
    }
    entry.installedTier = 0;
    return true;
  }

  // Armor is for the player's own cars. A bike has nowhere to carry plating.
  public static func CanBeArmored(vehicle: wref<VehicleObject>) -> Bool {
    return IsDefined(vehicle) && vehicle.IsPlayerVehicle() && !IsDefined(vehicle as BikeObject);
  }

  // The tier fitted to this vehicle, if it is one that can carry armor.
  public static func TierOf(vehicle: wref<VehicleObject>) -> ArmorTier {
    let system: ref<ArmorInstallSystem>;
    if !ArmorInstallSystem.CanBeArmored(vehicle) {
      return ArmorTier.None;
    }
    system = ArmorInstallSystem.Get(vehicle.GetGame());
    if !IsDefined(system) {
      return ArmorTier.None;
    }
    return system.GetInstalled(vehicle.GetRecordID());
  }

  // The share of incoming damage this vehicle's armor stops, 0.0 to 0.95.
  public static func ReductionFor(vehicle: wref<VehicleObject>) -> Float {
    let tier: ArmorTier = ArmorInstallSystem.TierOf(vehicle);
    if Equals(tier, ArmorTier.None) {
      return 0.0;
    }
    return ClampF(Cast<Float>(ArmorSettings.Get().ReductionPercent(tier)) / 100.0, 0.0, 0.95);
  }

  // The share of its acceleration this vehicle loses to the armor's weight, 0.0 to 0.95.
  public static func WeightPenaltyFor(vehicle: wref<VehicleObject>) -> Float {
    let tier: ArmorTier = ArmorInstallSystem.TierOf(vehicle);
    if Equals(tier, ArmorTier.None) {
      return 0.0;
    }
    return ClampF(Cast<Float>(ArmorSettings.Get().WeightPercent(tier)) / 100.0, 0.0, 0.95);
  }
}

@addField(VehicleObject)
public let m_gvaWeightTracking: Bool;

@addField(VehicleObject)
public let m_gvaLastSpeed: Float;

// Speed the previous correction took off, in m/s.
@addField(VehicleObject)
public let m_gvaLastCorrection: Float;

// The armor's weight is not written into the car's physics record, which other
// mods manage. Instead, each frame the car gains speed under throttle, part of
// that gain is pushed back out of it.
public abstract class ArmorWeight {
  public static func Tick(vehicle: ref<VehicleObject>, timeDelta: Float, throttle: Float) -> Void {
    let penalty: Float;
    let forward: Vector4;
    let origin: Vector4;
    let speed: Float;
    let gain: Float;
    let correction: Float;
    let impulse: Float;
    let evt: ref<PhysicalImpulseEvent>;
    if !IsDefined(vehicle) {
      return;
    }
    penalty = ArmorInstallSystem.WeightPenaltyFor(vehicle);
    if penalty <= 0.0 || timeDelta <= 0.0 || timeDelta > 0.25 {
      vehicle.m_gvaWeightTracking = false;
      return;
    }
    forward = vehicle.GetWorldForward();
    speed = Vector4.Dot(vehicle.GetLinearVelocity(), forward);
    if !vehicle.m_gvaWeightTracking {
      vehicle.m_gvaWeightTracking = true;
      vehicle.m_gvaLastSpeed = speed;
      vehicle.m_gvaLastCorrection = 0.0;
      return;
    }
    // What the drivetrain added since the last frame: the change in speed, plus
    // what the last correction removed from it.
    gain = speed - vehicle.m_gvaLastSpeed + vehicle.m_gvaLastCorrection;
    vehicle.m_gvaLastSpeed = speed;
    vehicle.m_gvaLastCorrection = 0.0;
    // Only forward acceleration under throttle; a jump of more than 3 m/s in one
    // frame is a collision or a teleport, not the engine.
    if throttle < 0.05 || speed < 0.0 || gain <= 0.0 || gain > 3.0 {
      return;
    }
    correction = penalty * gain;
    impulse = correction * vehicle.GetTotalMass();
    origin = vehicle.GetWorldPosition();
    evt = new PhysicalImpulseEvent();
    // The push goes in at the car's origin. Half a metre higher levers the nose
    // up against the tyres' drive; below the origin it pins the car in place.
    evt.worldPosition.X = origin.X;
    evt.worldPosition.Y = origin.Y;
    evt.worldPosition.Z = origin.Z;
    evt.worldImpulse.X = -forward.X * impulse;
    evt.worldImpulse.Y = -forward.Y * impulse;
    evt.worldImpulse.Z = -forward.Z * impulse;
    vehicle.QueueEvent(evt);
    vehicle.m_gvaLastCorrection = correction;
  }
}

@wrapMethod(DriveEvents)
public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  ArmorWeight.Tick(scriptInterface.owner as VehicleObject, timeDelta, scriptInterface.GetActionValue(n"Accelerate"));
}

@wrapMethod(DriverCombatEvents)
public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
  wrappedMethod(timeDelta, stateContext, scriptInterface);
  ArmorWeight.Tick(scriptInterface.owner as VehicleObject, timeDelta, scriptInterface.GetActionValue(n"Accelerate"));
}

// Every hit on a vehicle - gunfire, collisions and explosions - has its damage
// settled here, so scaling the result covers all three.
@wrapMethod(DamageSystem)
private final func ProcessVehicleTarget(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
  let reduction: Float;
  wrappedMethod(hitEvent, cache);
  if hitEvent.projectionPipeline {
    return;
  }
  reduction = ArmorInstallSystem.ReductionFor(hitEvent.target as VehicleObject);
  if reduction > 0.0 {
    hitEvent.attackComputed.MultAttackValue(1.0 - reduction);
  }
}

// Hits on V while mounted pass through here. The plating of the car V is sitting
// in takes its share off them too.
@wrapMethod(DamageSystem)
public final func ProcessOnVehicleMitigation(hitEvent: ref<gameHitEvent>) -> Void {
  let player: ref<PlayerPuppet>;
  let vehicle: wref<VehicleObject>;
  let reduction: Float;
  wrappedMethod(hitEvent);
  player = hitEvent.target as PlayerPuppet;
  if !IsDefined(player) || hitEvent.attackData.HasFlag(hitFlag.CannotModifyDamage) {
    return;
  }
  vehicle = player.GetMountedVehicle();
  if !IsDefined(vehicle) || !ArmorSettings.Get().protectOccupants {
    return;
  }
  reduction = ArmorInstallSystem.ReductionFor(vehicle);
  if reduction > 0.0 {
    hitEvent.attackComputed.MultAttackValue(1.0 - reduction);
  }
}
