// Garage Vehicle Armor
// The Armor screen: one row per tier, each with its own action button.
module GarageVehicleArmor

import GarageCore.*
import GarageCore.Bridge.*
import GarageCore.Screens.*
import GarageCore.UI.*
import Codeware.UI.*

// What is for sale and what it costs.
public abstract class ArmorCatalog {
  public static func Label(tier: ArmorTier) -> String {
    switch tier {
      case ArmorTier.Light:
        return UTF8StrUpper(ArmorText("GarageVehicleArmor-Light"));
      case ArmorTier.Medium:
        return UTF8StrUpper(ArmorText("GarageVehicleArmor-Medium"));
      case ArmorTier.Heavy:
        return UTF8StrUpper(ArmorText("GarageVehicleArmor-Heavy"));
    }
    return "";
  }

  public static func Price(tier: ArmorTier) -> Int32 {
    switch tier {
      case ArmorTier.Light:
        return 20000;
      case ArmorTier.Medium:
        return 45000;
      case ArmorTier.Heavy:
        return 90000;
    }
    return 0;
  }

  // Labour for putting back a tier the vehicle has already paid for.
  public static func RefitFee(tier: ArmorTier) -> Int32 {
    return ArmorCatalog.Price(tier) / 10;
  }
}

public class ArmorScreen extends GarageScreen {
  private let m_screenManager: wref<ScreenManager>;
  private let m_root: wref<inkCanvas>;
  private let m_vehicleText: wref<inkText>;
  private let m_balanceText: wref<inkText>;
  private let m_lightText: wref<inkText>;
  private let m_mediumText: wref<inkText>;
  private let m_heavyText: wref<inkText>;
  private let m_lightBtn: ref<SimpleButton>;
  private let m_mediumBtn: ref<SimpleButton>;
  private let m_heavyBtn: ref<SimpleButton>;

  public func SetScreenManager(manager: ref<ScreenManager>) -> Void {
    this.m_screenManager = manager;
  }

  protected cb func OnCreate() {
    let root = new inkCanvas();
    root.SetName(n"gvaArmorScreen");
    root.SetAnchor(inkEAnchor.Fill);
    root.SetVisible(false);

    this.CreateBackButton(root);
    this.CreateTitle(root, UTF8StrUpper(ArmorText("GarageVehicleArmor-Title")), 60.0);

    let column = new inkVerticalPanel();
    column.SetName(n"gvaColumn");
    column.SetAnchor(inkEAnchor.Centered);
    column.SetAnchorPoint(new Vector2(0.5, 0.5));
    column.SetChildMargin(new inkMargin(0.0, 12.0, 0.0, 12.0));
    column.Reparent(root);

    this.m_vehicleText = this.AddText(column, n"gvaVehicle", 48, n"Bold", GarageColors.AccentBlue());
    this.m_balanceText = this.AddText(column, n"gvaBalance", 30, n"Regular", GarageColors.AccentBlue());
    this.m_lightText = this.AddText(column, n"gvaLightText", 36, n"Regular", new HDRColor(1.0, 0.81, 0.06, 1.0));
    this.m_lightBtn = this.CreateStandardButton(n"gvaLightBtn", this.ButtonText("Install"), 300.0, this.AddButtonHolder(column, n"gvaLightHolder"), n"OnLightClick");
    this.m_mediumText = this.AddText(column, n"gvaMediumText", 36, n"Regular", new HDRColor(1.0, 0.81, 0.06, 1.0));
    this.m_mediumBtn = this.CreateStandardButton(n"gvaMediumBtn", this.ButtonText("Install"), 300.0, this.AddButtonHolder(column, n"gvaMediumHolder"), n"OnMediumClick");
    this.m_heavyText = this.AddText(column, n"gvaHeavyText", 36, n"Regular", new HDRColor(1.0, 0.81, 0.06, 1.0));
    this.m_heavyBtn = this.CreateStandardButton(n"gvaHeavyBtn", this.ButtonText("Install"), 300.0, this.AddButtonHolder(column, n"gvaHeavyHolder"), n"OnHeavyClick");

    this.m_root = root;
    this.SetRootWidget(root);
  }

  private func AddText(parent: ref<inkCompoundWidget>, name: CName, size: Int32, style: CName, tint: HDRColor) -> ref<inkText> {
    let text = new inkText();
    text.SetName(name);
    text.SetText("");
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(style);
    text.SetFontSize(size);
    text.SetTintColor(tint);
    text.SetHorizontalAlignment(textHorizontalAlignment.Center);
    text.Reparent(parent);
    return text;
  }

  // A centred holder so each button sits under its own line of text.
  private func AddButtonHolder(parent: ref<inkCompoundWidget>, name: CName) -> ref<inkHorizontalPanel> {
    let holder = new inkHorizontalPanel();
    holder.SetName(name);
    holder.SetHAlign(inkEHorizontalAlign.Center);
    holder.Reparent(parent);
    return holder;
  }

  private func ButtonText(name: String) -> String {
    return UTF8StrUpper(ArmorText("GarageVehicleArmor-" + name));
  }

  // One of the tier lines, with the tier's name, its damage reduction and a price filled in.
  private func LineText(name: String, tier: ArmorTier, price: Int32) -> String {
    let text = ArmorText("GarageVehicleArmor-" + name);
    text = StrReplace(text, "{NAME}", ArmorCatalog.Label(tier));
    text = StrReplace(text, "{PERCENT}", IntToString(ArmorSettings.Get().ReductionPercent(tier)));
    return StrReplace(text, "{PRICE}", FormatPrice(price));
  }

  public func Show() -> Void {
    this.m_isVisible = true;
    this.m_root.SetVisible(true);
    this.Populate();
  }

  public func Hide() -> Void {
    this.m_isVisible = false;
    this.m_root.SetVisible(false);
  }

  // The vehicle in the garage, if it is one that can carry armor.
  private func GetFittableVehicle() -> wref<VehicleObject> {
    let settings = GarageSettings.GetInstance(this.GetGameInstance());
    if !IsDefined(settings) || !ArmorInstallSystem.CanBeArmored(settings.garageVehicle) {
      return null;
    }
    return settings.garageVehicle;
  }

  // What pressing the button would cost: nothing to remove, the fee to refit, else full price.
  private func CostOf(vehicle: wref<VehicleObject>, tier: ArmorTier) -> Int32 {
    let installs = ArmorInstallSystem.Get(vehicle.GetGame());
    if Equals(installs.GetInstalled(vehicle.GetRecordID()), tier) {
      return 0;
    }
    if installs.IsOwned(vehicle.GetRecordID(), tier) {
      return ArmorCatalog.RefitFee(tier);
    }
    return ArmorCatalog.Price(tier);
  }

  private func Populate() -> Void {
    let settings = GarageSettings.GetInstance(this.GetGameInstance());
    let vehicle = this.GetFittableVehicle();
    let balance = LuaBridge.GetPlayerMoney();
    if IsDefined(vehicle) && IsDefined(settings) {
      this.m_vehicleText.SetText(settings.sellVehicleDisplayName);
    } else {
      this.m_vehicleText.SetText(ArmorText("GarageVehicleArmor-NoVehicle"));
    }
    this.m_balanceText.SetText(StrReplace(ArmorText("GarageVehicleArmor-Balance"), "{AMOUNT}", FormatPrice(balance)));
    this.PopulateRow(vehicle, ArmorTier.Light, balance, this.m_lightText, this.m_lightBtn);
    this.PopulateRow(vehicle, ArmorTier.Medium, balance, this.m_mediumText, this.m_mediumBtn);
    this.PopulateRow(vehicle, ArmorTier.Heavy, balance, this.m_heavyText, this.m_heavyBtn);
  }

  private func PopulateRow(vehicle: wref<VehicleObject>, tier: ArmorTier, balance: Int32, line: wref<inkText>, btn: ref<SimpleButton>) -> Void {
    let usable = false;
    let installs: ref<ArmorInstallSystem>;
    let cost: Int32;
    let btnRoot: wref<inkWidget>;
    if !IsDefined(vehicle) {
      line.SetText(this.LineText("ForSale", tier, ArmorCatalog.Price(tier)));
      btn.SetText(this.ButtonText("Install"));
    } else {
      installs = ArmorInstallSystem.Get(vehicle.GetGame());
      cost = this.CostOf(vehicle, tier);
      if Equals(installs.GetInstalled(vehicle.GetRecordID()), tier) {
        line.SetText(this.LineText("Installed", tier, 0));
        btn.SetText(this.ButtonText("Remove"));
        usable = true;
      } else {
        if installs.IsOwned(vehicle.GetRecordID(), tier) {
          line.SetText(this.LineText("RefitFor", tier, cost));
          btn.SetText(this.ButtonText("Refit"));
        } else {
          line.SetText(this.LineText("ForSale", tier, cost));
          btn.SetText(this.ButtonText("Install"));
        }
        usable = balance >= cost;
      }
    }
    btn.SetDisabled(!usable);
    btnRoot = btn.GetRootWidget();
    if IsDefined(btnRoot) {
      btnRoot.SetOpacity(usable ? 1.0 : 0.35);
    }
  }

  // Removes the tier if it is fitted; otherwise charges for it and fits it in
  // place of whatever the vehicle had.
  private func Act(tier: ArmorTier) -> Void {
    let vehicle = this.GetFittableVehicle();
    let installs: ref<ArmorInstallSystem>;
    let cost: Int32;
    if !IsDefined(vehicle) {
      return;
    }
    installs = ArmorInstallSystem.Get(vehicle.GetGame());
    if Equals(installs.GetInstalled(vehicle.GetRecordID()), tier) {
      installs.Remove(vehicle.GetRecordID());
    } else {
      cost = this.CostOf(vehicle, tier);
      if LuaBridge.GetPlayerMoney() >= cost && ArmorBridge.Charge(cost) {
        installs.Install(vehicle.GetRecordID(), tier);
        ArmorBridge.Complete(StrReplace(ArmorText("GarageVehicleArmor-Fitted"), "{NAME}", ArmorCatalog.Label(tier)));
      }
    }
    // Stay on the screen so the result shows against the other tiers.
    this.Populate();
  }

  protected cb func OnLightClick(widget: wref<inkWidget>) -> Bool {
    this.Act(ArmorTier.Light);
    return false;
  }

  protected cb func OnMediumClick(widget: wref<inkWidget>) -> Bool {
    this.Act(ArmorTier.Medium);
    return false;
  }

  protected cb func OnHeavyClick(widget: wref<inkWidget>) -> Bool {
    this.Act(ArmorTier.Heavy);
    return false;
  }

  // Registered by CreateBackButton
  protected cb func OnBackClick(widget: wref<inkWidget>) -> Bool {
    if IsDefined(this.m_screenManager) {
      this.m_screenManager.GoBack();
    }
    return false;
  }
}
