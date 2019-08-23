#!/bin/bash

shopt -s extglob

usage() {
    cat <<EOF

usage: ${0##*/^} [flags] [options]

    Options:

      --basic, -b                           Download and install the basic packages to the OS
      --sudouser, -su  <user> <passphrase>  Create name to user with root/sudo privilegies

      --helpbasic, -hb                      Show a list of what will be installed
      --help, -h                            Show this message

EOF
}

set_basic() {
    sudo pacman -S git --noconfirm --needed        # Verifica e instala o git
    git clone https://aur.archlinux.org/yay.git    # Clona o Yay AUR Helper 
    cd yay
    makepkg -si --noconfirm --needed               # Instala o Yay AUR Helper
    cd .. && rm -fr yay                            # Retorna e remove a pasta do git
    yay -Syu                                       # Atualiza todos os pacotes

}

set_sudouser() {

    [[ -z "$2" ]] && echo "Set name user." && exit 1     # Verifica se foi passado algum argumento
    suser=$(echo "$2" | tr -d ' _-' | tr 'A-Z' 'a-z')    # Verifica se está dentro dos padrões

    echo "Your user: $suser. Enter and repeat your passphrase:"
      sudo useradd -m -g users -G wheel,storage,power,video,network -s /bin/bash "$suser"                # Adiciona o usuário
      sudo passwd "$suser"                                                                               # Senha do usuário
      sudo pacman -S sudo --noconfirm --needed                                                           # Instala o pacote sudo
      sudo sed -i "s/^root ALL=(ALL) ALL$/root ALL=(ALL) ALL\n${suser} ALL=(ALL) ALL\n/" /etc/sudoers    # Adiciona o usuário ao sudo
      echo "Success: user created and included on group sudo"
      exit
}

get_basic() {
    cat <<EOF

* First it will download and install git and the Yay - An AUR Helper
* Second it will download and install the follow list:
    - vim                                   A console text editor
    - ranger                                A VIM-inspired filemanager for the console
    - calcurse                              A calendar and scheduling application for the console
    - systemd-numlockontty                  System service + script to automatically activate numpad on ttys
EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then    # Se nada for digitado ou for igual á oppção
    usage
    exit $(( $# ? 0 : 1 ))
fi

case "$1" in

    "--basic"|"-b") set_basic ;;               # Função de download e instalação dos pacotes
    "--sudouser"|"-su") set_sudouser "$@";;    # Adiciona um usuário como sudo
    "--helpbasic"|"-hb") get_basic ;;          # Mostra o que será instalado
    "--help"|"-h") usage ;;                    # Mostra as opções
    *) echo "Invalid option." && usage ;;      # Mostra as opções caso digite algo inválido

esac

exit 0
