
alias prop_team_traits = script_traits[0]
alias scale_amount = 15
alias players_per_hunter = 5
alias prop_min_point_distance = script_option[2]
alias attached = player.object[0]
alias weapon = player.object[1]
alias kill_points = script_option[0]
alias killed_points = script_option[1]

alias temp_object_0 = global.object[0]
alias temp_int_0 = global.number[0]
alias temp_int_1 = global.number[1]
alias temp_int_2 = global.number[2]
alias temp_player_0 = global.player[0]

alias prop_team_widget = script_widget[0]
alias close_widget = script_widget[1]

declare player.timer[0] = 3
alias close_timer = player.timer[0]

declare player.timer[1] = 5
alias announce_timer = player.timer[1]
alias announced = player.number[0]

for each player do
	current_player.announce_timer.set_rate(-100%)
	if current_player.announce_timer.is_zero() and current_player.announced != 1 then
		current_player.announced = 1
		send_incident(custom_game_start, current_player, no_player)
		game.show_message_to(current_player, none, "Prop Hunt Revamped")
		game.show_message_to(current_player, none, "Made by Sofasleeper5")
		
	end
end

for each player do
	if current_player.team == team[0] then
		current_player.set_round_card_title("Hide as a prop!\nMade by Sofasleeper5")
	end
	if current_player.team == team[1] then
		current_player.set_round_card_title("Hunt down disguised players!\nMade by Sofasleeper5")
	end
end
	

--handle prop team attributes
function attach_closest()
	alias distance = temp_int_0
	alias closest_distance = temp_int_1
	alias closest_object = temp_object_0
	closest_distance = 32767
	closest_object = no_object
	for each object with label "prop" do
		if current_object != current_player.attached then
			distance = current_object.get_distance_to(current_player.biped)
			if distance < closest_distance or closest_object == no_object	then
				closest_distance = distance
				closest_object = current_object
			end
		end
	end
	current_player.attached.detach()
	closest_object.copy_rotation_from(current_player.biped, true)
	closest_object.attach_to(current_player.biped, 0, 0, 0, relative)
	current_player.attached = closest_object
	game.show_message_to(current_player, none, "Switched prop")
end

on local: do
	for each player do
		if current_player.team == team[0] then
			alias to_scale = temp_object_0
			current_player.biped.set_scale(scale_amount)
			to_scale = current_player.get_armor_ability()
			to_scale.set_scale(scale_amount)
			to_scale = current_player.try_get_weapon(primary)
			to_scale.set_scale(scale_amount)
			to_scale = current_player.try_get_weapon(secondary)
			to_scale.set_scale(scale_amount)
		end
	end
end
			
for each player do
	if current_player.team == team[0] then
		current_player.apply_traits(prop_team_traits)
		
		alias aa = temp_object_0
		aa = current_player.get_armor_ability()
		if aa.is_in_use() then
			game.show_message_to(current_player, none, "aa in use")
			aa.delete()
			aa = no_object
		end
		aa = current_player.get_armor_ability()
		if aa == no_object  and current_player.biped != no_object then
			game.show_message_to(current_player, none, "No aa detected")
			aa = current_player.biped.place_at_me(active_camo_aa, none, never_garbage_collect, 0, 0, 0, none)
			aa.attach_to(current_player.biped, 0, 0, 0, relative)
			attach_closest()
		end
		
		alias weapon = temp_object_0
		weapon = current_player.try_get_weapon(primary)
		if not weapon.is_of_type(detached_machine_gun_turret) then
			current_player.weapon.delete()
			current_player.weapon = current_player.biped.place_at_me(detached_machine_gun_turret, none, never_garbage_collect, 0, 0, 0, none)
			current_player.add_weapon(current_player.weapon)
		end
		if current_player.biped == no_object then
			current_player.attached = no_object
			current_player.weapon.delete()
		end
		
		prop_team_widget.set_visibility(current_player, true)
		prop_team_widget.set_value_text("Use armor ability to switch to closest prop\nBe close to hunters for points")
		
	end
	if current_player.team == team[1] then
		current_player.attached = no_object
		prop_team_widget.set_visibility(current_player, false)
		current_player.weapon.delete()
	end
end



do --handle team assignment
	alias hunter_count = temp_int_0
	hunter_count = 0
	alias player_count = temp_int_1
	player_count = 0
	alias desired_hunter_count = temp_int_2
	for each player do
		player_count += 1
		if current_player.team == team[1] then
			hunter_count += 1
		end
	end
	desired_hunter_count = player_count
	desired_hunter_count /= players_per_hunter
	desired_hunter_count += 1
	if player_count == 1 then
		desired_hunter_count = 0
	end
	for each player randomly do
		if hunter_count < desired_hunter_count and current_player.team == no_team then
			current_player.team = team[1]
			hunter_count += 1
		end
	end
	for each player randomly do
		if hunter_count < desired_hunter_count then
			current_player.biped.kill(false)
			current_player.team = team[1]
			hunter_count += 1
			game.show_message_to(current_player, none, "Autobalance: changed to hunter")
		end
	end
	for each player randomly do
		if hunter_count > desired_hunter_count and current_player.team == team[1] then
			current_player.team = team[0]
			current_player.biped.kill(false)
			hunter_count -= 1
			game.show_message_to(current_player, none, "Autobalance: changed to prop")
		end
	end
	for each player do
		if current_player.team == no_team then
			current_player.team = team[0]
		end
	end
end


for each player do --handle scoring
	close_widget.set_visibility(current_player, false)
	if current_player.team == team[0] then
		alias prop_biped = temp_object_0
		prop_biped = current_player.biped
		alias distance_to_hunter = temp_int_0
		alias min_distance_to_hunter = temp_int_1
		min_distance_to_hunter = 32767
		for each player do
			if current_player.team == team[1] then
				distance_to_hunter = current_player.biped.get_distance_to(prop_biped)
				if distance_to_hunter < min_distance_to_hunter then
					min_distance_to_hunter = distance_to_hunter
				end
			end
		end
		
		if min_distance_to_hunter < prop_min_point_distance then
			close_widget.set_visibility(current_player, true)
			close_widget.set_text("Close enough to hunter for points!")
		end
		current_player.close_timer.set_rate(-100%)
		if current_player.close_timer.is_zero() then
			current_player.close_timer.reset()
			if min_distance_to_hunter < prop_min_point_distance then
				current_player.score += 1
			end
		end
	end
	if current_player.killer_type_is(guardians | suicide | kill | betrayal | quit) then
		alias killer = temp_player_0
		killer = current_player.get_killer()
		killer.score += kill_points
		current_player.score -= killed_points
	end
end

if game.round_time_limit > 0 and game.round_timer.is_zero() then
   game.end_round()
end