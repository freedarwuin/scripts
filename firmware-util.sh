#!/bin/bash
#
# This script offers provides the ability to update the
# Legacy Boot payload, set boot options, and install
# a custom coreboot firmware for supported
# ChromeOS devices
#
# Created by Mr.Chromebox <mrchromebox@gmail.com>
#
# May be freely distributed and modified as needed,
# as long as proper attribution is given.
#

#path to directory where script is saved
script_dir="$(dirname $(readlink -f $0))"

#donde estan las cosas
script_url="https://raw.githubusercontent.com/freedarwuin/scripts/main/"

#Garantizar la salida de las herramientas del sistema en en-us para su análisis
export LC_ALL=C

#establecer directorio de trabajo
if grep -q "Chrom" /etc/lsb-release ; then
    # necesario para Chrome OS/Chromium OS v82+
    mkdir -p /usr/local/bin
    cd /usr/local/bin
else
    cd /tmp
fi

# Limpiar pantalla / mostrar banner
printf "\ec"
echo -e "\nScript de utilidad de firmware freedarwuin al iniciarse"

#verificar parámetros de línea de comando, certificados CrossS expirados
if ! curl -sLo /dev/null https://mrchromebox.tech/index.html || [[ "$1" = "-k" ]]; then
    export CURL="curl -k"
else
    export CURL="curl"
fi

if [ ! -d "$script_dir/.git" ]; then
    script_dir="."

    #Obtener scripts de soporte
    echo -e "\nDescargando archivos de soporte..."
    rm -rf firmware.sh >/dev/null 2>&1
    rm -rf functions.sh >/dev/null 2>&1
    rm -rf sources.sh >/dev/null 2>&1
    $CURL -sLO ${script_url}firmware.sh
    rc0=$?
    $CURL -sLO ${script_url}functions.sh
    rc1=$?
    $CURL -sLO ${script_url}sources.sh
    rc2=$?
    if [[ $rc0 -ne 0 || $rc1 -ne 0 || $rc2 -ne 0 ]]; then
        echo -e "Error al descargar uno o más archivos necesarios; no se puede continuar"
        exit 1
    fi
fi

source $script_dir/sources.sh
source $script_dir/firmware.sh
source $script_dir/functions.sh

#establecer directorio de trabajo
cd /tmp

#hacer cosas de configuración
prelim_setup
prelim_setup_result="$?"

#Guardar el estado de configuración para solucionar problemas
diagnostic_report_save
troubleshooting_msg=(
    " * El informe de diagnóstico se ha guardado en /tmp/mrchromebox_diag.txt"
    " * ir a https://forum.chrultrabook.com/ Para ayuda"
)
if [ "$prelim_setup_result" -ne 0 ]; then
    IFS=$'\n'
    echo "La instalación de la utilidad de firmware de freedarwuin no fue exitosa" > /dev/stderr
    echo "${troubleshooting_msg[*]}" > /dev/stderr
    exit 1
fi

#show menu

trap 'check_unsupported' EXIT
function check_unsupported() {
    if [ "$isUnsupported" = true ]; then
        IFS=$'\n'
        echo "La utilidad de firmware de freedarwuin no reconoció su dispositivo" > /dev/stderr
        echo "${troubleshooting_msg[*]}" > /dev/stderr
    fi
}

menu_fwupdate
