# $(owner) is this player's own UUID (see streak_theft_check.mcfunction).
# For every slot a streak item could sit in, and every streak_item tier
# (1/2/3/4), reject anything whose streak_owner doesn't match $(owner) - i.e.
# it was picked up off a downed player rather than earned by this one.
$execute if items entity @s weapon.mainhand *[custom_data~{streak_item:1}] unless items entity @s weapon.mainhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.mainhand"}
$execute if items entity @s weapon.mainhand *[custom_data~{streak_item:2}] unless items entity @s weapon.mainhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.mainhand"}
$execute if items entity @s weapon.mainhand *[custom_data~{streak_item:3}] unless items entity @s weapon.mainhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.mainhand"}
$execute if items entity @s weapon.mainhand *[custom_data~{streak_item:4}] unless items entity @s weapon.mainhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.mainhand"}

$execute if items entity @s weapon.offhand *[custom_data~{streak_item:1}] unless items entity @s weapon.offhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.offhand"}
$execute if items entity @s weapon.offhand *[custom_data~{streak_item:2}] unless items entity @s weapon.offhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.offhand"}
$execute if items entity @s weapon.offhand *[custom_data~{streak_item:3}] unless items entity @s weapon.offhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.offhand"}
$execute if items entity @s weapon.offhand *[custom_data~{streak_item:4}] unless items entity @s weapon.offhand *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"weapon.offhand"}

$execute if items entity @s armor.head *[custom_data~{streak_item:1}] unless items entity @s armor.head *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.head"}
$execute if items entity @s armor.head *[custom_data~{streak_item:2}] unless items entity @s armor.head *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.head"}
$execute if items entity @s armor.head *[custom_data~{streak_item:3}] unless items entity @s armor.head *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.head"}
$execute if items entity @s armor.head *[custom_data~{streak_item:4}] unless items entity @s armor.head *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.head"}

$execute if items entity @s armor.chest *[custom_data~{streak_item:1}] unless items entity @s armor.chest *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.chest"}
$execute if items entity @s armor.chest *[custom_data~{streak_item:2}] unless items entity @s armor.chest *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.chest"}
$execute if items entity @s armor.chest *[custom_data~{streak_item:3}] unless items entity @s armor.chest *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.chest"}
$execute if items entity @s armor.chest *[custom_data~{streak_item:4}] unless items entity @s armor.chest *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.chest"}

$execute if items entity @s armor.legs *[custom_data~{streak_item:1}] unless items entity @s armor.legs *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.legs"}
$execute if items entity @s armor.legs *[custom_data~{streak_item:2}] unless items entity @s armor.legs *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.legs"}
$execute if items entity @s armor.legs *[custom_data~{streak_item:3}] unless items entity @s armor.legs *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.legs"}
$execute if items entity @s armor.legs *[custom_data~{streak_item:4}] unless items entity @s armor.legs *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.legs"}

$execute if items entity @s armor.feet *[custom_data~{streak_item:1}] unless items entity @s armor.feet *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.feet"}
$execute if items entity @s armor.feet *[custom_data~{streak_item:2}] unless items entity @s armor.feet *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.feet"}
$execute if items entity @s armor.feet *[custom_data~{streak_item:3}] unless items entity @s armor.feet *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.feet"}
$execute if items entity @s armor.feet *[custom_data~{streak_item:4}] unless items entity @s armor.feet *[custom_data~{streak_owner:$(owner)}] run function killstreak:streak_theft_reject {slot:"armor.feet"}
