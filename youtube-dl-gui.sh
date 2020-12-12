#!/bin/bash

function netcheck {
    wget -q --spider http://google.com

    if [ $? -eq 0 ]; then
        echo "internet bağlantısı var."
    else
        zenity --warning \
        --text="Bu çalışabilmesi için internet bağlantısı gerkmektedir."
        exit 1
    fi
}


## apt check

if [[ $(command -v apt) != "" ]] ; then
    echo "Debian Tabanlı Dağıtım Tespit Edildi..."
else
    echo "Eğer Zenity Ve Youtube-Dl Sisteminizde Yüklü İse Betiğin Çalışması İçin Kaynak Kodlarından 5.,6.,7.,8.,9.,10. Satırları Siliebilirsiniz."
    exit 1
fi

## zenity check

if [[ $(command -v zenity) != "" ]] ; then
    echo "Zenity Tespit Edildi..."
else
    netcheck
    pkexec apt update
    pkexec apt install zenity
fi

if [[ $(command -v youtube-dl) != "" ]] ; then
    echo "Youtube-Dl Tespit Edildi..."
else
    netcheck
    pkexec apt update
    pkexec apt install youtube-dl
fi

function download {
    (
echo "10" ; sleep 0.3
echo "# Video Kaynağı Doğrulanıyor" ; sleep 0.3 # sadece boş ama hoş :D
echo "20" ; sleep 0.3
echo "# Video Kaynağından Veri Alınıyor" ; sleep 0.3 # sadece boş ama hoş :D
echo "50" ; sleep 0.3
echo "This Video indiriliyor" ; youtube-dl -f "${1}" "${link}"
echo "75" ; sleep 1
echo "# Video $PWD Dizinine İndirildi." ; sleep 1 # sadece boş ama hoş :D
echo "100" ; sleep 1
) |
zenity --progress \
  --title="Youtube-dl Gui" \
  --text="Youtube-dl Gui..." \
  --percentage=0

if [ "$?" = -1 ] ; then
        zenity --error \
          --text="Video İndirme İşlemi Kullanıcı Tarafından İptal Edildi."
        exit 0
fi
}

while :; do
    netcheck
    link=$(zenity --entry --title "Youtube-dl  ( çıkmak için 'exit' yazın!! )" --text "indirmek istediğiniz youtube videosunun linkini giriniz: ")
    if [[ ${link} =~ ^(exit|EXIT|EXİT|exıt) ]] ; then
        exit 0
    elif [[ ${link} = "" ]] ; then
        zenity --warning \
        --text="link Değişkeni Boş Olamaz!!"
        echo "Link Değişkeni Boş Olamaz Çıkılıyor!"
        exit 1
    fi
    netcheck
    chkvideo=$(youtube-dl -F $link &> /dev/null ; echo $?)
    if [[ $chkvideo != "0" ]] ; then
        zenity --warning \
        --text="Girdiğin Link Hatalı!!."
        echo "Link Hatalı Çıkılıyor!"
        exit 1
    fi

    echo $chkvideo

    choice=$(zenity --list --text="İndirmek istediğiniz video formatını seçiniz" --column= --hide-header mp4-18 mp4-137 exit)
    echo ${choice}
    if [[ ${choice} = "mp4-18" ]] ; then
        videoinfoline=$(youtube-dl -F ${link} | awk '{print $1}' | grep -n 18 | tr ":" " " | awk '{print $1}')
        videoinfo=$(youtube-dl -F ${link} | awk "NR==${videoinfoline}")
        if zenity --width=700 --height=100 --question --text="$videoinfo indirilsinmi??" ; then
            download 18
            exit 0
        else
            #zenity --info --text="You pressed \"No\"!"
            exit 0
        fi
    elif [[ ${choice} = "mp4-137" ]] ; then
        videoinfoline=$(youtube-dl -F ${link} | awk '{print $1}' | grep -n 137 | tr ":" " " | awk '{print $1}')
        videoinfo=$(youtube-dl -F ${link} | awk "NR==${videoinfoline}")
        if zenity --width=700 --height=100 --question --text="$videoinfo indirilsinmi??" ; then
            download 137
            exit 0
        else
            #zenity --info --text="You pressed \"No\"!"
            exit 0
        fi
    elif [[ ${choice} = "exit" ]] ; then
        exit 0
    fi
done