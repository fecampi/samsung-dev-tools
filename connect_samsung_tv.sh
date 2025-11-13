#!/bin/bash

# Change directory and list contents
cd devices/samsung || { echo "Erro: Não foi possível acessar o diretório devices/samsung"; exit 1; }
ls

# Path to store TV data
TV_DATA_FILE="tv_data.txt"

# Load saved TVs from the file
load_tv_data() {
    if [ ! -f "$TV_DATA_FILE" ]; then
        touch "$TV_DATA_FILE"
    fi
    mapfile -t tv_list < "$TV_DATA_FILE"
}

# Save a new TV to the file
save_tv_data() {
    echo "$1 - $2" >> "$TV_DATA_FILE"
    echo "Dispositivo $1 salvo com sucesso."
}

# Display saved TVs
display_saved_tvs() {
    echo "TVs salvas:"
    nl -w2 -s". " "$TV_DATA_FILE"
}

# Connect to the TV
connect_tv() {
    echo "Conectando a TV:"
    load_tv_data

    if [ ${#tv_list[@]} -gt 0 ]; then
        echo ""
        echo "Deseja usar uma tv salva ou adicionar uma nova?"
        echo "1. Usar TV salva"
        echo "2. Adicionar nova tv"
        read -p "Escolha uma opção: " choice
    else
        choice=2
    fi

    case $choice in
        1)
            display_saved_tvs
            read -p "Escolha o número da TV: " tv_choice
            selected_tv=$(sed -n "${tv_choice}p" "$TV_DATA_FILE")
            IP_TV=$(echo "$selected_tv" | awk -F' - ' '{print $2}')
            ;;
        2)
            read -p "Digite o endereço IP da sua TV: " IP_TV
            ./sdb connect "$IP_TV":26101

            if ./sdb devices | grep -q "$IP_TV"; then
                DEVICE_NAME=$(./sdb devices | grep "$IP_TV" | awk '{print $3}')
                save_tv_data "$DEVICE_NAME" "$IP_TV"
            else
                echo "Erro: Não foi possível conectar à TV. Verifique o endereço IP e as configurações de desenvolvedor."
                exit 1
            fi
            ;;
        *)
            echo "Opção inválida. Por favor, tente novamente."
            connect_tv
            return
            ;;
    esac

    # Attempt to connect to the TV
    ./sdb connect "$IP_TV":26101

    # Verify if the connection was successful
    if ./sdb devices | grep -q "$IP_TV"; then
        echo "Conexão bem-sucedida com a TV."
    else
        echo "Erro: Não foi possível conectar à TV. Verifique o endereço IP e as configurações de desenvolvedor."
        exit 1
    fi
}

# Select and install a TPK file
install_tpk() {
    echo "Seleção de TPK"
    echo ""
    ls tpks/*.tpk | cat -n
    read -p "Escolha o número do arquivo TPK que deseja instalar: " option
    selected_file=$(ls tpks/*.tpk | sed -n "${option}p")

    if [ -z "$selected_file" ]; then
        echo "Opção inválida. Por favor, escolha um número válido."
        exit 1
    else
        echo "Instalando o arquivo: $selected_file"
        ./sdb install "$selected_file"
        if [ $? -eq 0 ]; then
            echo "Instalação concluída com sucesso."
        else
            echo "Erro: A instalação falhou."
            exit 1
        fi
    fi
}

# Capture logs using sdb
capture_logs() {
    echo "Executando 'sdb dlog' para capturar logs..."
    ./sdb dlog
}

# Capture logs, save to a timestamped file, and display them
capture_and_save_logs() {
    # Ensure logs directory exists
    mkdir -p logs

    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="logs/logs_$TIMESTAMP.txt"
    echo "Capturando logs e salvando em $LOG_FILE..."

    echo "Você deseja visualizar todos os logs, apenas os logs do Player, logs da Aplicação, ou logs do Tizen + Globo Play?"
    echo "1. Ver todos os logs"
    echo "2. Ver apenas logs do Player (I/TIZEN_N_PLAYER)"
    echo "3. Ver apenas logs da Aplicação (W/GLOBOPLAY-PL)"
    echo "4. Ver logs do Tizen + Globo Play (I/TIZEN_N_PLAYER e W/GLOBOPLAY-PL)"
    read -p "Escolha uma opção: " log_choice

    case $log_choice in
        1)
            ./sdb dlog | tee "$LOG_FILE"
            ;;
        2)
            ./sdb dlog | grep "I/TIZEN_N_PLAYER" | tee "$LOG_FILE"
            ;;
        3)
            ./sdb dlog | grep "W/GLOBOPLAY-PL" | tee "$LOG_FILE"
            ;;
        4)
            ./sdb dlog | grep -E "I/TIZEN_N_PLAYER|W/GLOBOPLAY-PL" | tee "$LOG_FILE"
            ;;
        *)
            echo "Opção inválida. Por favor, tente novamente."
            capture_and_save_logs
            return
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo "Logs salvos com sucesso em $LOG_FILE."
    else
        echo "Erro ao capturar os logs."
    fi
}

# Return to the main menu
return_to_menu() {
    echo ""
    echo "Você deseja instalar outro TPK, visualizar os logs ou capturá-los em um arquivo?"
    echo "1. Instalar outro TPK"
    echo "2. Capturar e salvar Logs"
    echo "3. Sair"
    read -p "Escolha uma opção: " option
    case $option in
        1)
            install_tpk
            return_to_menu
            ;;
        2)
            capture_and_save_logs
            return_to_menu
            ;;
        3)
            echo "Saindo..."
            exit 0
            ;;
        *)
            echo "Opção inválida. Por favor, tente novamente."
            return_to_menu
            ;;
    esac
}

# Start the connection process
connect_tv
return_to_menu
