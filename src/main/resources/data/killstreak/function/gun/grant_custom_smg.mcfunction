# Grant: Custom SMG (automatic, mag 30, 3 mags total)
# Loaded: 30 rounds | Reserve: 60 rounds
$give @s jeg:custom_smg[jeg:gun_ammo=30,custom_data={streak_item:1,streak_owner:$(owner)},enchantments={"killstreak:contract_of_the_gods":1},custom_name={text:"Custom SMG",color:"gold",italic:false}] 1
$give @s jeg:pistol_ammo[custom_data={streak_item:1,streak_owner:$(owner)},enchantments={"killstreak:contract_of_the_gods":1}] 60
