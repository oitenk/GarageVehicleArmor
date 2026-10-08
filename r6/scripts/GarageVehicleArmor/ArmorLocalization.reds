// Garage Vehicle Armor
// Text shown by the mod, registered with Codeware's localization system so it can
// be translated.
//
// To add a language, copy ArmorLanguageEnglish into a new class (in a file of its
// own), translate the second string of every line and leave the first alone, then
// return the new class for that language from ArmorLocalizationProvider.GetPackage
// below. {NAME}, {PERCENT}, {PRICE} and {AMOUNT} are filled in by the mod, so keep
// them in. The vehicle name comes from the game and is already translated.
//
// The Mod Settings page is written in English only.
module GarageVehicleArmor

import Codeware.Localization.*

public class ArmorLocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      // case n"fr-fr": return new ArmorLanguageFrench();
      default: return new ArmorLanguageEnglish();
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

public class ArmorLanguageEnglish extends ModLocalizationPackage {
  protected func DefineTexts() -> Void {
    // Service button in the garage hub, and the screen's title
    this.Text("GarageVehicleArmor-Title", "Armor");

    // The three tiers
    this.Text("GarageVehicleArmor-Light", "Light Armor");
    this.Text("GarageVehicleArmor-Medium", "Medium Armor");
    this.Text("GarageVehicleArmor-Heavy", "Heavy Armor");

    // Buttons
    this.Text("GarageVehicleArmor-Install", "Install");
    this.Text("GarageVehicleArmor-Remove", "Remove");
    this.Text("GarageVehicleArmor-Refit", "Refit");

    // Lines on the screen
    this.Text("GarageVehicleArmor-NoVehicle", "No vehicle to armor");
    this.Text("GarageVehicleArmor-Balance", "Balance: {AMOUNT}");
    this.Text("GarageVehicleArmor-ForSale", "{NAME} (-{PERCENT}% damage) - {PRICE} eddies");
    this.Text("GarageVehicleArmor-Installed", "{NAME} (-{PERCENT}% damage) - installed");
    this.Text("GarageVehicleArmor-RefitFor", "{NAME} (-{PERCENT}% damage) - refit for {PRICE} eddies");

    // Garage's notification after a purchase
    this.Text("GarageVehicleArmor-Fitted", "{NAME} fitted");
  }
}

// Text in the language the game is set to.
public func ArmorText(key: String) -> String {
  let text: String = GetLocalizedTextByKey(StringToName(key));
  return Equals(text, "") || Equals(text, key) ? key : text;
}
