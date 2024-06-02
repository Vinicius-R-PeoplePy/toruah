extends Control

@onready var label = $/root/level/Control/ColorRect/ColorRectDepositoFim/processando
@onready var timer = $/root/level/Control/ColorRect/ColorRectDepositoFim/Timer
@onready var deposito_confirmar_button = $/root/level/Control/ColorRect/ColorRectDeposito/Label/confirmar
@onready var sacar_confirmar_button = $/root/level/Control/ColorRect/ColorRectSacar/confirma
@onready var deposito_amount_input = $/root/level/Control/ColorRect/ColorRectDeposito/Label/LineEdit
@onready var sacar_amount_input = $/root/level/Control/ColorRect/ColorRectSacar/saque/LineEdit
@onready var error_labels = [$/root/level/Control/ColorRect/ColorRectDeposito/Erro, $/root/level/Control/ColorRect/ColorRectSacar/Erro]

@onready var account_number_input = $/root/level/Control/ColorRect/ColorRectDepositoConta/LineEdit
@onready var agency_number_input = $/root/level/Control/ColorRect/ColorRectDepositoConta/LineEdit2

@onready var player_script = load("res://player.gd")
var player_instance

var messages = ["Processando solicitação\n meleca...", "Validando melecas...", "Envio de melecas concluído"]
var current_message_index = 0
var current_char_index = 0

var message_display_time = 10.0  # seconds
var char_typing_speed = 0.1  # seconds per character
var time_passed = 0.0
var typing = true  # Tracks if currently typing

func _ready():
	player_instance = player_script.new()
	add_child(player_instance)
	player_instance.load_saldo_from_save_data()
	load_player_customization()
	
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	start_typing_message()
	check_balance_and_update_buttons()
	deposito_amount_input.connect("text_changed", Callable(self, "_on_deposito_amount_input_changed"))
	sacar_amount_input.connect("text_changed", Callable(self, "_on_sacar_amount_input_changed"))

func load_player_customization():
	var customization_data = CustomizationData.get_customization()
	for key in customization_data.keys():
		var color = Color(customization_data[key])
		update_player_appearance(key, color)

func update_player_appearance(key, color):
	match key:
		"cor_de_pele":
			player_instance.get_node("Node2D/skin").modulate = color
		"blusa":
			player_instance.get_node("Node2D/blusa").modulate = color
		"olhos":
			player_instance.get_node("Node2D/olhos").modulate = color
		"cabelo":
			player_instance.get_node("Node2D/cabelo").modulate = color
		"calca":
			player_instance.get_node("Node2D/calca").modulate = color
		"sapatos":
			for shoe in player_instance.get_node("Node2D/sapatos").get_children():
				shoe.modulate = color

func start_message_display():
	current_message_index = 0
	current_char_index = 0
	label.text = ""
	time_passed = 0.0
	typing = true
	timer.start(char_typing_speed)

func _on_Timer_timeout():
	if typing:
		if current_char_index < messages[current_message_index].length():
			label.text += messages[current_message_index][current_char_index]
			current_char_index += 1
		else:
			typing = false
			timer.start(message_display_time)  # Start the timer for display time
	else:
		timer.stop()
		current_message_index += 1
		if current_message_index < messages.size():
			start_typing_message()
		else:
			label.text = "Envio de melecas concluído"
			$/root/level/Control/ColorRect/ColorRectDepositoFim.hide()
			$/root/level/Control/ColorRect/ColorRectDepositoConta.hide()
			$/root/level/Control/ColorRect/ColorRectDeposito.hide()
			$/root/level/Control/ColorRect/ColorRectSacar.hide()
			$/root/level/Control/ColorRect/ColorRectSacar.hide()
			for error_label in error_labels:
				error_label.hide()

func start_typing_message():
	current_char_index = 0
	label.text = ""
	time_passed = 0.0
	typing = true
	timer.start(char_typing_speed)

func update_saldo_label():
	var player_saldo = player_instance.get_saldo()
	$/root/level/Control/ColorRectSaldo/saldo.text = "Saldo: " + str(player_saldo)

func _on_depositar_pressed():
	$/root/level/Control/ColorRect/ColorRectDeposito.show()

func _on_Depositovoltar_pressed():
	$/root/level/Control/ColorRect/ColorRectDeposito.hide()
	for error_label in error_labels:
		error_label.hide()

func _on_Depositoconfirmar_pressed():
	$/root/level/Control/ColorRect/ColorRectDepositoConta.show()
	check_balance_and_update_buttons()
	for error_label in error_labels:
		error_label.hide()

func _on_DepositoContavoltar_pressed():
	$/root/level/Control/ColorRect/ColorRectDepositoConta.hide()
	for error_label in error_labels:
		error_label.hide()

func _on_DepositoContaenviar_pressed():
	var amount = deposito_amount_input.text.to_int()
	var account_number = account_number_input.text
	var agency_number = agency_number_input.text
	
	if player_instance.get_saldo() >= amount:
		$/root/level/Control/ColorRect/ColorRectDepositoFim.show()
		start_message_display()
		
		player_instance.update_and_save_saldo(amount)

		var transaction_details = "Depósito: " + str(amount) + ", Conta: " + account_number + ", Agência: " + agency_number

		player_instance.transaction_history.append({"tipo": "depósito", "valor": transaction_details})

		update_saldo_label()

		deposito_amount_input.text = ""
		account_number_input.text = ""
		agency_number_input.text = ""
	else:
		error_labels[0].show()

func _on_sair_pressed():
	$/root/level/Control/ColorRect.hide()
	for error_label in error_labels:
		error_label.hide()
		player_instance.call_deferred("queue_free")

func _on_sacar_pressed():
	$/root/level/Control/ColorRect/ColorRectSacar.show()

func _on_Sacarvoltar_pressed():
	$/root/level/Control/ColorRect/ColorRectSacar.hide()
	for error_label in error_labels:
		error_label.hide()

func _on_Sacar_confirmar_button_pressed():
	check_balance_and_update_buttons()
	var amount = sacar_amount_input.text.to_int()
	if player_instance.get_saldo() >= amount:
		$/root/level/Control/ColorRect/ColorRectDepositoFim.show()
		start_message_display()
		player_instance.update_and_save_saldo(amount)
		player_instance.transaction_history.append({"tipo": "saque", "valor": amount})
		update_saldo_label()
		$/root/level/Control/ColorRect/ColorRectSacar.hide()
		$/root/level/Control/ColorRect/ColorRectDeposito.hide()
		sacar_amount_input.text = ""
	else:
		error_labels[1].show()

func _on_SacarContavoltar_pressed():
	$/root/level/Control/ColorRect/ColorRectSacar.hide()
	for error_label in error_labels:
		error_label.hide()

func _on_Historico_button_pressed():
	$/root/level/Control/ColorRect/ColorRectHistorico.show()
	var history_label = $/root/level/Control/ColorRect/ColorRectHistorico/historico
	history_label.text = ""
	for transaction in player_instance.transaction_history:
		if transaction["tipo"] == "depósito":
			history_label.text += "" + str(transaction["valor"]) + "\n"
		elif transaction["tipo"] == "saque":
			history_label.text += "Saque: " + str(transaction["valor"]) + "\n"

func _on_deposito_amount_input_changed(new_text):
	check_balance_and_update_buttons()

func _on_sacar_amount_input_changed(new_text):
	check_balance_and_update_buttons()

func check_balance_and_update_buttons():
	var player_saldo = player_instance.get_saldo()
	var deposito_amount = deposito_amount_input.text.to_int()
	var sacar_amount = sacar_amount_input.text.to_int()
	player_instance.update_and_save_saldo(player_saldo)
	player_instance.update_melecas_label()

	if deposito_amount_input.text.strip_edges() == "" or deposito_amount <= 0:
		deposito_confirmar_button.disabled = true
		error_labels[0].hide()
	elif player_saldo < deposito_amount:
		deposito_confirmar_button.disabled = true
		error_labels[0].show()
	else:
		deposito_confirmar_button.disabled = false
		error_labels[0].hide()

	if sacar_amount_input.text.strip_edges() == "" or sacar_amount <= 0:
		sacar_confirmar_button.disabled = true
		error_labels[1].hide()
	elif player_saldo < sacar_amount:
		sacar_confirmar_button.disabled = true
		error_labels[1].show()
	else:
		sacar_confirmar_button.disabled = false
		error_labels[1].hide()

func _on_Historicovoltar_pressed():
	$/root/level/Control/ColorRect/ColorRectHistorico.hide()

func _on_saldo_pressed():
	$/root/level/Control/ColorRectSaldo.show()

func _on_Saldovoltar_pressed():
	$/root/level/Control/ColorRectSaldo.hide()
