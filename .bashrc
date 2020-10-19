#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ll='ls -lrtAh --group-directories-first'
alias sudo='sudo '
alias ls='ls --color=auto'
alias grep='\grep --color=auto'
alias myip='curl ifconfig.me'
alias LAST='echo "---------------successful-logins-----------------" && last | tac | tail && echo "-------------------sshd-log---------------------" && sudo journalctl -u sshd | tail'
alias pacman='pacman --color always'
alias SPEED='speedometer -r enp4s0 -t enp4s0 -s'
alias VIDS="ps aux | grep vlc | tail -n +3 | sed 's/^.*vlc //'"
alias tm='transmission-remote $(cat ~/.tminject)'
alias snote='cat ~/linuxnotes | grep -i -C 5'
alias screenlock='qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock'
alias mirrors='sudo reflector --country "United States" -l 30 --sort rate'
alias dmesg='dmesg -L=always'
alias gpu='sudo cat /sys/kernel/debug/dri/0/amdgpu_pm_info | tail -15 | head -11'
alias freemem="sudo sync; echo 1 | sudo tee /proc/sys/vm/drop_caches"
alias freemem3="sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches"
alias rapid="firefox https://portal.cardaccesssite.com/web/rapid/login &> /dev/null &"
alias lofi="mpv --no-video --volume=50 'https://www.youtube.com/watch?v=5qap5aO4i9A'"
alias fountain="mpv --no-video --volume=50 -- 'https://www.youtube.com/watch?v=0TQeUVu8Ca0'"
alias gamestudymusic="mpv --no-video --volume=60 'https://www.youtube.com/watch?v=P1k4jGwhKF0' 2> /dev/null"
alias rm="rm -i"
alias mv="mv -i"
alias ix="curl -F 'f:1=<-' ix.io"
# PS1='[\e[31m\u\e[0m@\e[96m\h\e[0m \W]\$ '

# Begin Talzahr's code
tube (){
	lynx "https://youtube.com/results?search_query=$(echo $* | sed 's/[ ]/+/g')"
}

google () {
	w3m "https://www.google.com/"
}

ddg () {
	w3m "https://duckduckgo.com/?t=ffnt&q=$(echo $* | sed 's/[ ]/+/g')"
}

archwiki () {
	w3m "https://wiki.archlinux.org/index.php?search=$(echo $* | sed 's/[ ]/+/g')"
}

fancontrolfix () {
	[[ $# -ne 1 ]] && echo "Just provide a value for hwmon. ex. \"fancontrolfix 1\" updates to hwmon1 in /etc/fancontrol" &&\
		return 1
	sudo sed -i "s/hwmon./hwmon$1/g" /etc/fancontrol
	[[ $? -gt 0 ]] && echo "Error: /etc/fancontrol could not be written." && return 1
	cat /etc/fancontrol
	sudo systemctl restart fancontrol.service
	successrestart="$?"
	sudo sed -i "s/hwmonval=./hwmonval=$1/" /usr/bin/gputemp
	[[ $successrestart -eq 0 ]] && echo -e "\\nfancontrol.service successfully restarted." &&\
	 	return 0 ||\
	 	echo -e "\\nError: fancontrol.service could not be restarted."
	return 1
}

gputemploop () {
	while true; do gputemp; echo "    ----"; sleep 10; done
}

vpn () {
	[[ $# -ne 1 ]] && echo "Provide 'up' or 'down' argument for wg-quick." && return 1
	[[ $1 == "up" ]] && sudo wg-quick up client
	[[ $1 == "down" ]] && sudo wg-quick down client
	return 0
}

DU () {
[[ "$#" -eq 0 ]] && dulistparam="." || dulistparam="$1"
	dulist=($(du -hd1 -- "$dulistparam" 2> /dev/null |\
		 sed 's/^.*K\t.*$//g;s/^.*M\t.*//g;s/\t/---/g' |\
		 sort -nr)) &&\
		 for i in "${dulist[@]}"; do
			 echo "$i"
		 done | sed 's/---/\t/g'
}

cv () {
	grep "USA" ~/.cache/corona |\
	sed 's/║//g;s/│/:/g;s/\s*//g' |\
	awk -F':' '{print "Confirmed: "$3 "\nNew Confirmed: "$4 "\nDeaths: "$5 "\nNew Deaths: "$6 "\nCritical: "$9 "\nCases/1M: "$10}' > ~/.cache/coronaoutput &&\
	lolcat ~/.cache/coronaoutput
}

cvupdate () {
	touch $HOME/.cache/corona
	[[ $? -gt 0 ]] && "error, cannot access" || echo "Updating..."
	curl -s https://corona-stats.online?top=10 > $HOME/.cache/corona
}

aurgit () {
    mkdir -p "$HOME/.cache/aurpkg"
    pushd "$HOME/.cache/aurpkg" > /dev/null || return 1
    git clone "https://aur.archlinux.org/$1.git" || return 2
    cd "$1"
    makepkg -si
    local makepkgerr="$?"
    popd > /dev/null
    [[ "$makepkgerr" -gt 0 ]] && return 3 || return 0
}

pq () {
	pqRawData=($(curl https://api.2b2t.dev/prioq 2> /dev/null |\
	 sed 's/^\[//;s/\]$//;s/\"//g;s/\,/ /g'))
	[[ $? -gt 0 ]] && echo "pq: error retrieving data from api.2b2t.dev" && return 1
	pqEpoch=$((${pqRawData[0]}/1000))
	pqTimeSince=$(($(date +'%s')-$pqEpoch))
	pqTimeSince=$(date -u -d @"$pqTimeSince" +'%-Mm %-Ss')
	echo ">>> 2b2t queue information <<<"
	echo "Last update:            $pqTimeSince ago"
	echo "Players in prio queue:  ${pqRawData[1]}"
	echo "Approximate wait time:  ${pqRawData[2]}"
}

seen () {
	[[ ! $# -eq 1 ]] && echo "seen: incorrect number of arguments. Just provide a player name." && return 1
	# Strip characters that are not permitted in an MC player name. ( 'a-z' 'A-Z' '0-9' '_' )
	param1=$(echo "$1" | tr -cd "[:alnum:]_")
	seenRawTime=$(curl -- https://api.2b2t.dev/seen?username="$param1" 2> /dev/null |\
	 sed 's/^.*\"\:\"//;s/\".*$//')
	[[ $? -gt 0 ]] && echo "seen: error retrieving data from api.2b2t.dev" && return 3
	[[ $seenRawTime == "[]" ]] && echo "seen: error, player $param1 not found." && return 2
	seenLocalSeconds=$(date -u "+%s")
	seenSeconds=$(date -u "+%s" -d "$seenRawTime")
	seenDiff=$(($seenLocalSeconds-$seenSeconds))
	#echo "DEBUG seenLocalSeconds = $seenLocalSeconds, seenSeconds = $seenSeconds, seenDiff = $seenDiff"
	seenDays="$(($seenDiff/86400))d, "
	[[ $seenDays == "0d, " ]] && seenDays=""
	seenHours="$(((($seenDiff/3600)) % 24))h, "
	[[ $seenHours == "0h, " ]] && seenHours=""
	seenMins="$(((($seenDiff/60)) % 60))m"
	echo "2b2t player $param1 last seen $seenDays$seenHours$seenMins ago"
}

cleannames () {
	while true; do
		read -p "Rename all files in $(pwd)? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			* ) echo "User-inititated abort"; return 2;;
		esac
	done

	SAVEIFS=$IFS IFS=$'\n'
	ifile=($(find . -maxdepth 1 -type f -printf '%f\n'))
	IFS=$SAVEIFS
	ofile=($(find . -maxdepth 1 -type f -printf '%f\n' | sed 's/ /-/g' | tr -cd "[:alnum:]-_.\n" | tr -s '-'))
	ct=0
	[[ ! ${#ifile[@]} -eq ${#ofile[@]} ]] && echo "error: number of files not matching" && return 1
	for i in "${ifile[@]}"; do
		[[ ! "$i" == "${ofile[$ct]}" ]] && mv -- "$i" ./"${ofile[$ct]}"
		(( ct++ ))
	done
}

vol () {
	echo "current volume: $(pamixer --get-volume-human)"
	while true; do
		read -n1 -p "(u=up, d=down, m=toggle mute, q=quit): " volOpt
		case $volOpt in
			u)
				pamixer --allow-boost -i 5 && echo -e "\\n$(pamixer --get-volume-human)";;
			d)
				pamixer --allow-boost -d 5 && echo -e "\\n$(pamixer --get-volume-human)";;
			m)
				pamixer -t && echo -e "\\n$(pamixer --get-volume-human)";;
			q)
				return 0;;
			*)
				echo -e "\\ninvalid option";;
		esac
	done
	return 0
}

l () {
	[[ $# -lt 1 ]] && echo "l: Will launch the command and parameter(s) asynchonously." && return 1
	which $1 &> /dev/null
	[[ $? -gt 0 ]] && echo "l: command $1 not found" && return 2
	( $* &> /dev/null ) &
	return 0
}

wr () {
	kill -9 $(pgrep Cemu) 2> /dev/null
	[[ $? -gt 0 ]] && echo "Cemu is not running." ||\
	echo "SIGKILL sent to Cemu."
	kill $(pgrep wineserver) 2> /dev/null
	[[ $? -gt 0 ]] && echo "wineserver is not running." ||\
	echo "SIGTERM sent to wineserver."
}

bye () {
	echo -e "\\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\\n  Updating and rebooting...\\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\\n"
	touch $HOME/elements/temptouch
	sudo pacman -Syu --noconfirm && sudo systemctl reboot
}

jellyfinperms () {
	echo "checking permissions in ~/jellyfin..."

	#permissions
	local filesnum=$(find ~/jellyfin/ -type f \! -perm 664 | wc -l)
	echo "    files with incorrect permissions: $filesnum"
	[[ $filesnum -gt 0 ]] && find ~/jellyfin/ -type f \! -perm 664 -exec sudo chmod 664 {} \;

	local dirnum=$(find ~/jellyfin/ -type d \! -perm 775 | wc -l)
	echo "    directories with incorrect permissions: $dirnum"
	[[ $dirnum -gt 0 ]] && find ~/jellyfin/ -type d -perm 755 -exec sudo chmod 775 {} \;

	#ownserhip
	echo -e "\\nchecking ownership in ~/jellyfin..."

	local unum=$(find ~/jellyfin/ \! -user jellyfin | wc -l)
	echo "    entities not owned by jellyfin: $unum"
	[[ $unum -gt 0 ]] && find ~/jellyfin/ \! -user jellyfin -exec sudo chown jellyfin:jellyfin {} \;

	echo -e \\n$(( "$filesnum" + "$dirnum" )) "permissions changed"
	echo "$unum ownerships changed"
}

w2x () {
	if [[ ! $@ ]]; then
	       	echo "usage: w2x <noise> <scale> <'p' or 'i' for photo/illust> <filename>"
		echo "set variables INDIR and OUTDIR for input and output paths"
		echo "INDIR: $INDIR"
		echo "OUTDIR: $OUTDIR"
	fi	
	local indir_default=/home/talzahr/elements2/pics/Prefs/temp/slide/
	local outdir_default=/home/talzahr/elements2/pics/Prefs/temp/slide/upscale/
	local photo_model=/usr/share/waifu2x-converter-cpp/photo
	local photomode

	[[ -z $INDIR ]] && INDIR=$indir_default
	[[ -z $OUTDIR ]] && OUTDIR=$outdir_default
	
	[[ $3 == "p" ]] && local photo_mode="--model-dir $photo_model"
	[[ -z $4 ]] && echo "need an input filename, exiting" && return 1
	if [[ $1 == "n" ]]; then
		local mode="scale"
		local noise=""
	else
		local mode="noise-scale"
		local noise="--noise-level $1"
	fi
	local scale="$2"
	shift
	shift
	shift
	local ifile=$@
	
	waifu2x-converter-cpp -m "$mode" "$noise" --scale-ratio "$scale" -i "$INDIR$ifile" -o $OUTDIR -c 8 "$photo_mode"
}

getout () {
	tdiff="$((1611162000-$(date +%s)))"
	tmins="$(((($tdiff/60)) % 60))"
	thours="$(((($tdiff/3600)) % 24))"
	tdays="$(($tdiff/86400))"
	tsecs="$(($tdiff % 60))"
	echo $tdays\d $thours\h $tmins\m $tsecs\s
}

biggest () {
	[[ ! $@ ]] && echo "Needs at least a path. exiting" && return 1
	[[ -z $2 ]] && local tail="10" || local tail="$2"
	find $1 -type f -printf '%kK    %p\n' | sort -n | tail -"$tail"
	read -p "Would you like to remove these files? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		sudo rm $(find $1 -type f -printf '%k    %p\n' |\
		       	sort -n | tail -"$2" | awk '{print $2}')
		echo "Done."
	else
		return 0
	fi
}

newmainline () {
	local currver=$(curl -L 'http://www.kernel.org' 2> /dev/null |\
	       	grep -A1 "mainline:" | tail -1 | sed 's/^.*<strong>//;s/<.*$//')
	local myver=$(pacman -Qi linux-talzahr | grep "Version" |\
	       	sed 's/^.* //;s/-.*$//;s/rc/-rc/')
	local pkgdir=/home/talzahr/nvme-home/build/linux-talzahr/
	#echo "kernel.org: $currver installed: $myver"
	if [ "$currver" == "$myver" ]; then
		echo "$myver is the latest kernel version. Nothing to do."
		return 1
	else
		echo -e "Kernel.org mainline:     $currver\\nInstalled linux-talzahr: $myver"
      echo -e "$(env | grep MAKEFLAGS)\\n"
		read -p "Would you like to upgrade to $currver? [y/N]" -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo -e "Beginning download and build of custom linux-talzahr.\\n\\n\\n"
			cd $pkgdir
			local currverpkg=$(echo "$currver" | sed 's/-//')
			sed -i "s/^_tag=v.*$/_tag=v$currver/;\
				s/^pkgver=.*$/pkgver=$currverpkg/" PKGBUILD
			makepkg -i --noconfirm
			echo -e "\\nCleaning up the build directory.\\n"
			rm -rf linux-talzahr/ pkg/ src/ && rm *.zst
		else
			return 0
		fi
	fi
}

#v () {
#	shellvars="$HOME/.local/share/shellvars.tmp"
#	touch $shellvars
#	if [[ ! $@ ]]; then
#		echo "-- custom local shell variables --"
#		cat $shellvars
#		echo ""
#		return 0
#	elif [[ $@ ]]; then
#		echo "$1	$
#	fi
#
#}

# Variables
dirgpu=$(readlink -f /sys/class/drm/card0/device)
build=/home/talzahr/nvme-home/build

export XDG_CONFIG_HOME="$HOME/.config"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/share/:/usr/local/share/"
export XDG_CACHE_HOME="$HOME/.cache"
export EDITOR="/usr/sbin/vim"
export MAKEFLAGS="-j$(nproc)"
export VISUAL=vim

echo 

# curl wttr.in/Abilene?0 --silent --max-time 4
echo "        --==BASh==--       <[Bourne Again SHell]>       --==BASh==--        " > ~/.local/share/bash-temp-output
echo " " >> ~/.local/share/bash-temp-output
df -hT --exclude-type=tmpfs --exclude-type=devtmpfs >> ~/.local/share/bash-temp-output
echo " " >> ~/.local/share/bash-temp-output
neofetch >> ~/.local/share/bash-temp-output
reminder -s 2> /dev/null >> ~/.local/share/bash-temp-output
echo -e \\n" $(getout) until the Constitutional end of term." >> ~/.local/share/bash-temp-output
lolcat ~/.local/share/bash-temp-output
rm -f ~/.local/share/bash-temp-output

##-----------------------------------------------------
## status
## Added by synth-shell
## https://github.com/andresgongora/synth-shell/
#if [ -f /home/talzahr/.config/synth-shell/status.sh ]; then
#	source /home/talzahr/.config/synth-shell/status.sh
#fi

##-----------------------------------------------------
## fancy-bash-prompt
## Added by synth-shell
## https://github.com/andresgongora/synth-shell/
if [ -f /home/talzahr/.config/synth-shell/fancy-bash-prompt.sh ]; then
	source /home/talzahr/.config/synth-shell/fancy-bash-prompt.sh
fi
