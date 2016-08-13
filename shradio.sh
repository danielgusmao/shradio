#!/bin/bash

#------------------------------------------------------------------------------#
# Data: 13 de Agosto de 2016
# Criado por: Juliano Santos [x_SHAMAN_x]
# Script: shRadio.sh
# Descrição: Script para execução de radios online atraves do serviço de stream
#------------------------------------------------------------------------------#

# Verifica se 'mplayer' está instalando
if [ ! -x "$(which mplayer)" ]; then
	echo "$(basename "$0"): Erro: 'mplayer' não está instalado."; exit 1; fi

# CONF
TMP_LISTEN=$(mktemp --tmpdir=/tmp shradio.XXXXXXXXXX)

#Icone
ICON_APP=/usr/share/icons/HighContrast/48x48/emblems/emblem-music.png

# Se o script for interrompido pelo usuário
trap '_exit' TERM INT

# Exit
function _exit()
{
	# Remove arquivo temporário.
	rm -f $TMP_LISTEN

	# Mata todos os processos do script
	kill -9 $(ps aux | grep -v grep | egrep "bash -c ListRadio|yad --list" | awk '{print $2}') \
			$(pidof mplayer) $BASHPID &>/dev/null

	exit 0
}

# Toca a rádio
function PlayRadio()
{
	local listen=$(echo "$*" | cut -d"|" -f3)	# Serviço de stream
	local genre=$(echo "$*" | cut -d"|" -f2)	# Gênero
	local radio=$(echo "$*" | cut -d"|" -f1)	# Nome da Radio
	
	# Se rádio for selecionada
	if [ "$listen" ]; then
		# Finaliza o processo 'mplayer' e todos o(s) subshell's 'ListRadio' em execução, com excessão do atual.
		kill -9 $(pidof mplayer) \
		$(ps aux | grep -v grep | grep "bash -c ListRadio" | grep -v "$genre" | awk '{print $2}') &>/dev/null; else return 0; fi

	# Executa o LISTEN da rádio em segundo plano e redireciona as informações para o arquivo 'TMP_LISTEN'
	mplayer "$listen" &>$TMP_LISTEN &
	# Variáveis locais.
	local Music RadioName Swap
	# Status de seleção da rádio pelo usuário
	local ini=0
	# Aguarda conexão com o servidor de stream
	for cont in $(seq 4); do 
		echo; sleep 1; done | yad --progress \
								  --fixed \
								  --center \
								  --no-buttons \
								  --title "$radio" \
								  --progress-text="Conectando '$listen'..." \
								  --auto-close --pulsate

	# Atualiza a cada '3' segundos as informações da rádio e armazena as informações em
	# 'Music' e 'RadioName'.
	while true
	do
		# Sincroniza informações da 'rádio'
		Music="$(cat $TMP_LISTEN | grep -i "StreamTitle" | awk 'END {print}' | cut -d'=' -f2- | cut -d';' -f1 | tr -d "['\"]")"
		RadioName="$(cat $TMP_LISTEN | egrep -i "^Name" | awk 'END {print}' | cut -d':' -f2-)"
		
		# Se a música mudou ou se a rádio foi selecionada pelo usuário, envia uma notificação
		# com as informações da nova faixa.
		if [ "$Music" != "$Swap" -o $ini -eq 0 ]; then
			Swap="$Music"							# Música atual.
			Music="${Music:-Desconhecido}"			# 'Desconhecido' Valor padrão
			RadioName="${RadioName:-Desconhecido}"  
			
			# Envia notificação
			notify-send --app-name="shRadio" --icon=$ICON_APP "$Music" "$RadioName"
			ini=1	# status
		fi
		sleep 3  # N> low cpu
		
	done 
}

function ListRadio()
{
	# Informações da(s) Radio(s)
	# Nome da Rádio: Armazenado no array NAME
	# url stream: Armazenado no array LISTEN
	# As variáveis são inicializadas de acordo com o gênero selecionado.
	# Gênero: $1 -> GENRE
	local GENRE="$1"
	local -a NAME LISTEN INDEX

	# Inicia as viariveis
	case $GENRE in
		rock)
			# Gênero: ROCK
			NAME=('Radio Paradise - Naim exclusive'
				  'Classic Rock Florida WWWSHERADIO HD'
				  '3001.fm - The very best of Classic-Rock'
				  'Rockhard Lossless'
				  'Digital Impulse - Rock Hits'
				  'Kirtang Pirate Radio'
				  '7radio'
				  'Radio Caroline 259 Gold - Live from Breskens - Holland s1'
				  'Audiophile Rock-Blues'
				  'Week-FM Rock')
			
			LISTEN=('http://37.130.228.60:8014'
					'http://us2.internet-radio.com:8039'
					'http://192.99.35.93:6578'
					'http://95.211.162.73:8000'
					'http://5.39.71.159:8871'
					'http://209.126.116.156:8127'
					'http://91.121.38.100:8190'
					'http://46.165.208.21:8253'
					'http://8.38.78.173:8280'
					'http://87.118.78.80:10170')
			;;
		jazz)
			# Gênero: JAZZ
			NAME=('Audiophile Jazz'
				  'Digital Impulse - Jazz'
				  'Hi On Line Jazz Radio'
				  'salm najar'
			      'PARTY VIBE RADIO : ROCK + COUNTRY + JAZZ + FOLK'
				  'combitrailerteam'
				  'Smooth Jazz Florida Plus HQ'
				  'OkoloJazza'
				  'Radio ClassicOne Live'
			      'WCFA 101.5')
			
			LISTEN=('http://8.38.78.173:8276'
					'http://5.39.71.159:8950'
					'http://109.169.27.91:29622'
					'http://109.169.27.91:30802'
					'http://www.partyviberadio.com:8020'
					'http://37.59.195.28:8334'
					'http://us1.internet-radio.com:8094'
					'http://109.170.8.130:80'
					'http://185.105.4.53:3000'
					'http://209.105.232.220:8574')
			;;
		country)
			# Gênero: COUNTRY
			NAME=('Tmefm Radio'
				  'DI Radio Digital impulse - Country'
				  'Country Rage Radio'
				  'OCRN'
				  'The ChillOut RooM'
				  'Kickin Up Your Bootz'
				  'Nashville FM 24/7 Nonstop Country Music-01'
				  'Regiohits Nu De Briljant Fm Jolanda'
				  'Blues After Hours Radio'
				  'WEST COAST Golden Radio')
			
			LISTEN=('http://uk3.internet-radio.com:8077'
					 'http://5.39.71.159:8110'
					 'http://198.27.80.205:5168'
					 'http://198.27.80.205:5096'
					 'http://95.154.202.117:31947'
					 'http://78.129.224.15:4974'
					 'http://46.231.87.20:8300'
					 'http://91.121.76.193:8208'
					 'http://london-dedicated.myautodj.com:8108'
					 'http://sv3.vestaradio.com:4370')
			;;
		blues)
			# Gênero: BLUES
			NAME=('DI Radio Digital Impulse - Blues'
				  'Audiophile Rock-Blues'
				  'Raven'
				  'DeBluesRadio.com'
				  'Radio ClassicOne Live'
				  'Kixedb Radio'
				  'Blues After Hours Radio'
				  'Deuces Stream: HellFire Blues Radio'
				  'XL-RadioFM: The Xtra LARGE Music Experience'
				  'WLDB1322 VOYAGERS BLUES')

			LISTEN=('http://5.39.71.159:8990'
					'http://8.38.78.173:8280'
					'http://184.95.47.178:9744'
					'http://178.20.171.30:8018'
					'http://185.105.4.53:3000'
					'http://us2.internet-radio.com:8369'
					'http://london-dedicated.myautodj.com:8108'
					'http://91.121.123.36:2401'
					'http://109.236.86.11:9006'
					'http://64.20.38.13:8028')
			;;
		classical)
			# Gênero: CLASSICAL
			NAME=('Hi On Line Classic Radio'
				  'Audiophile Classical'
				  'Davide of MIMIC'
				  'Radio Saiuz Classic'
				  'BCRFM Stream'
			      'Streaming Raagas'
				  'Radio ClassicOne Movie'
				  'Radio ClassicOne Live'
				  'Blue-and-Fire: Radio'
				  'Classic Top Tunes')
			
			LISTEN=('http://82.94.166.107:8088'
					'http://8.38.78.173:8274'
					'http://uk3.internet-radio.com:8180'
					'http://192.99.34.205:8352'
					'http://151.80.97.38:8246'
					'http://us2.internet-radio.com:8210'
					'http://185.105.4.53:3006'
					'http://185.105.4.53:3000'
					'http://176.28.8.38:8600'
					'http://66.90.103.144:8996')
			;;
		dance)
			# Gênero: DANCE
			NAME=('RaSat-Promo-Werbe-Stream'
				  'Radio-Satisfaction.de'
				  'New Dance Radio'
				  'DI Radio Digital Impulse - Best Dance 90s'
			      'MS BROADCASTING'
				  'jenny.fm - from the motherland of techno'
				  'Radio50plus Denmark'
				  'mZoleees SHOUTcast stream'
				  'Dance100.com'
				  'Radio Digitaal Stream')
			
			LISTEN=('http://81.169.215.5:8550'
					'http://81.169.231.225:15000'
					'http://jbstream.net:8074'
					'http://5.39.71.159:8643'
					'http://211.43.215.158:8294'
					'http://5.35.241.180:9000'
					'http://38.96.148.140:7838'
					'http://88.151.102.67:8008'
					'http://91.121.82.33:20624'
					'http://192.99.170.8:5170')
			;;
		heavy_metal)
			# Gênero: HEAVY_METAL
			NAME=('Rockhard Lossless'
				  'RockWorld24.com'
				  'AOR-ROCKS'
				  'Alchemical Internet Radio'
				  'The Metal Plague'
				  'MUSIK.ROCK (EXTREME)'
				  'WackenRadio.com'
				  'RockRadio1.Com'
				  'Radio Bloodstream'
				  'Prog Palace Radio')

			LISTEN=('http://95.211.162.73:8000'
					'http://51.255.235.165:5132'
					'http://167.114.64.181:8806'
					'http://uk3.internet-radio.com:11048'
					'http://142.4.217.133:8386'
					'http://95.141.24.24:80'
					'http://193.34.51.71:80'
					'http://77.74.192.50:8000'
					'http://uk1.internet-radio.com:8294'
					'http://206.217.215.59:80')
			;;
	esac

	# Lê o total de itens em NAME	
	for INDEX in $(seq 0 $((${#NAME[@]}-1))); do
		# Elemento na posição 'INDEX' em NAME e LISTEN
		# Imprime a linha com as informações da radio, mantendo o layout do controle 'list'
		printf "%s\n%s\n%s\n" "${NAME[$INDEX]}" "$GENRE" "${LISTEN[$INDEX]}"
		# Redireciona a saida para a janela 'list'
		# Se item for selecionado, executa 'PlayRadio' passando 'stdout' como parâmetro da função.
	done | PlayRadio $(yad --list \
							--listen \
							--center \
							--fixed \
							--width 500 \
							--height 400 \
							--kill-parent \
							--no-click \
							--title "Lista das rádios" \
							--text "Para ouvir, selecione a rádio e clique no botão '<b>Play</b>' ou\ndê dois cliques rápidos em cima do nome.\nEntão, uma boa música pra você. :) $RadioName\n\n<b>Rádios disponíveis:</b>" \
							--button 'Play!/usr/share/icons/Adwaita/22x22/actions/media-playback-start.png':0 \
							--hide-column=3 \
							--column "Nome" --column "Gênero" --column "Listen")

	return 0	
}

# Exporta funções e variáveis.
export -f ListRadio PlayRadio
export TMP_LISTEN ICON_APP

# Janela principal
yad --form \
	--center \
	--geomatry 400x600 \
	--fixed \
	--kill-parent \
	--image $ICON_APP \
	--button 'Sair!gtk-quit':1 \
	--title "[x_SHAMAN_x] shRadio online" \
	--text "Seja bem vindo ao '<b>shRadio</b>', seu script de rádio online.\nPara começar, escolha seu gênero músical clicando nas opções\nabaixo. Será exibida uma lista contendo as rádios disponíveis." \
	--field '':LBL '' \
	--field '<b>Gêneros:</b>':LBL \
	--field 'Rock!gtk-cdrom':BTN 'bash -c "ListRadio rock"'\
	--field 'Jazz!gtk-cdrom':BTN 'bash -c "ListRadio jazz"' \
	--field 'Country!gtk-cdrom':BTN 'bash -c "ListRadio country"' \
	--field 'Blues!gtk-cdrom':BTN 'bash -c "ListRadio blues"' \
	--field 'Clássica!gtk-cdrom':BTN 'bash -c "ListRadio classical"'\
	--field 'Dance!gtk-cdrom':BTN 'bash -c "ListRadio dance"' \
	--field 'Heavy Metal!gtk-cdrom':BTN 'bash -c "ListRadio heavy_metal"' 

# Finaliza
_exit
