// Garage Vehicle Armor
// Registers the "Armor" service with the Garage hub.
module GarageVehicleArmor

import GarageCore.Services.*
import GarageCore.Screens.*
import GarageCore.UI.*

public class ArmorRegistrar extends ServiceModuleRegistrar {
  public func Register(screenManager: ref<ScreenManager>, frame: ref<GarageFrame>) -> Void {
    let screen = new ArmorScreen();
    screen.CreateInstance();
    screen.SetScreenManager(screenManager);
    frame.AddScreen(screen);
    screenManager.RegisterScreen(n"gva_armor", screen);
  }

  public func GetDescriptors() -> array<ref<ServiceDescriptor>> {
    let descriptors: array<ref<ServiceDescriptor>>;
    let desc = new ServiceDescriptor();
    let cond = new ArmorVisibility();
    cond.requireOwned = true;
    desc.id = n"gva_armor";
    desc.label = UTF8StrUpper(ArmorText("GarageVehicleArmor-Title"));
    // Between Nitro (35) / Targeting (36) and Repair (40).
    desc.priority = 38;
    desc.visibilityConditions = cond;
    desc.clickHandler = new ArmorClickHandler();
    ArrayPush(descriptors, desc);
    return descriptors;
  }
}

// Only owned cars can be armored, so the button is hidden for bikes.
public class ArmorVisibility extends VisibilityConditions {
  public func IsMet(context: ref<GarageContext>) -> Bool {
    if !super.IsMet(context) {
      return false;
    }
    return ArmorInstallSystem.CanBeArmored(context.vehicle);
  }
}

public class ArmorClickHandler extends ServiceClickHandler {
  public func OnClick(screenManager: ref<ScreenManager>, context: ref<GarageContext>) -> Void {
    screenManager.ShowScreen(n"gva_armor");
  }
}
