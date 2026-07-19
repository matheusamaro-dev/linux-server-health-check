#!/usr/bin/env bash
# linux-server-health-check
# Diagnóstico seguro e somente leitura para servidores Linux.
# Compatível com distribuições que utilizam /proc, como Ubuntu, Debian e RHEL.

set -uo pipefail
export LC_ALL=C

readonly SCRIPT_VERSION="1.0.1"
readonly CHECK_TARGET="${CHECK_TARGET:-1.1.1.1}"
readonly CPU_WARN="${CPU_WARN:-80}"
readonly CPU_CRIT="${CPU_CRIT:-95}"
readonly MEM_WARN="${MEM_WARN:-85}"
readonly MEM_CRIT="${MEM_CRIT:-95}"
readonly DISK_WARN="${DISK_WARN:-80}"
readonly DISK_CRIT="${DISK_CRIT:-90}"

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  readonly RESET='\033[0m'
  readonly BOLD='\033[1m'
  readonly GREEN='\033[32m'
  readonly YELLOW='\033[33m'
  readonly RED='\033[31m'
  readonly CYAN='\033[36m'
else
  readonly RESET=''
  readonly BOLD=''
  readonly GREEN=''
  readonly YELLOW=''
  readonly RED=''
  readonly CYAN=''
fi

OVERALL_STATUS=0

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

line() {
  printf '%*s\n' 72 '' | tr ' ' '-'
}

section() {
  printf '\n%b%s%b\n' "$BOLD$CYAN" "$1" "$RESET"
  line
}

update_overall_status() {
  local new_status="$1"
  if (( new_status > OVERALL_STATUS )); then
    OVERALL_STATUS="$new_status"
  fi
}

print_metric() {
  local label="$1"
  local value="$2"
  local status="$3"
  local color="$GREEN"
  local status_code=0

  case "$status" in
    OK)       color="$GREEN"; status_code=0 ;;
    ATENCAO)  color="$YELLOW"; status_code=1 ;;
    CRITICO)  color="$RED"; status_code=2 ;;
    INFO)     color="$CYAN"; status_code=0 ;;
    *)        color="$CYAN"; status_code=0 ;;
  esac

  update_overall_status "$status_code"
  printf '%-24s %-31s %b[%s]%b\n' "$label" "$value" "$color" "$status" "$RESET"
}

status_for_percent() {
  local value="$1"
  local warn="$2"
  local crit="$3"

  if (( value >= crit )); then
    printf 'CRITICO'
  elif (( value >= warn )); then
    printf 'ATENCAO'
  else
    printf 'OK'
  fi
}

get_os_name() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf '%s' "${PRETTY_NAME:-${NAME:-Linux}}"
  else
    printf 'Linux'
  fi
}

get_uptime() {
  if uptime -p >/dev/null 2>&1; then
    uptime -p | sed 's/^up //'
  elif [[ -r /proc/uptime ]]; then
    awk '{
      seconds=int($1); days=int(seconds/86400); hours=int((seconds%86400)/3600); minutes=int((seconds%3600)/60);
      printf "%d dias, %d horas, %d minutos", days, hours, minutes
    }' /proc/uptime
  else
    printf 'N/A'
  fi
}

get_cpu_usage() {
  [[ -r /proc/stat ]] || { printf '0'; return; }

  local cpu user nice system idle iowait irq softirq steal guest guest_nice
  local total1 idle1 total2 idle2 delta_total delta_idle usage

  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  idle1=$((idle + iowait))
  total1=$((user + nice + system + idle + iowait + irq + softirq + steal))

  sleep 1

  read -r cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  idle2=$((idle + iowait))
  total2=$((user + nice + system + idle + iowait + irq + softirq + steal))

  delta_total=$((total2 - total1))
  delta_idle=$((idle2 - idle1))

  if (( delta_total <= 0 )); then
    printf '0'
    return
  fi

  usage=$((100 * (delta_total - delta_idle) / delta_total))
  printf '%s' "$usage"
}

get_memory_usage() {
  [[ -r /proc/meminfo ]] || { printf '0 0 0'; return; }

  awk '
    /^MemTotal:/ { total=$2 }
    /^MemAvailable:/ { available=$2 }
    END {
      if (total > 0) {
        used=total-available;
        printf "%d %d %d", (used*100/total), (used/1024), (total/1024)
      } else {
        printf "0 0 0"
      }
    }
  ' /proc/meminfo
}

get_cpu_count() {
  if command_exists nproc; then
    nproc
  elif command_exists getconf; then
    getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1'
  else
    printf '1'
  fi
}

get_network_info() {
  local interface='N/A'
  local local_ip='N/A'
  local gateway='N/A'

  if command_exists ip; then
    interface="$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')"
    gateway="$(ip route show default 2>/dev/null | awk 'NR==1 {print $3}')"
    local_ip="$(ip -o -4 addr show scope global 2>/dev/null | awk 'NR==1 {split($4,a,"/"); print a[1]}')"
  elif command_exists hostname; then
    local_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  fi

  printf '%s|%s|%s' "${interface:-N/A}" "${local_ip:-N/A}" "${gateway:-N/A}"
}

check_connectivity() {
  if ! command_exists ping; then
    printf 'INDISPONIVEL'
    return
  fi

  if ping -c 1 -W 2 "$CHECK_TARGET" >/dev/null 2>&1; then
    printf 'OK'
  else
    printf 'FALHA'
  fi
}

printf '%b' "$BOLD"
printf 'LINUX SERVER HEALTH CHECK v%s\n' "$SCRIPT_VERSION"
printf '%b' "$RESET"
printf 'Data: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf 'Modo: somente leitura\n'
line

section 'SISTEMA'
print_metric 'Hostname' "$(hostname 2>/dev/null || printf 'N/A')" 'INFO'
print_metric 'Sistema operacional' "$(get_os_name)" 'INFO'
print_metric 'Kernel' "$(uname -r 2>/dev/null || printf 'N/A')" 'INFO'
print_metric 'Arquitetura' "$(uname -m 2>/dev/null || printf 'N/A')" 'INFO'
print_metric 'Uptime' "$(get_uptime)" 'INFO'

section 'RECURSOS'

cpu_usage="$(get_cpu_usage)"
cpu_status="$(status_for_percent "$cpu_usage" "$CPU_WARN" "$CPU_CRIT")"
print_metric 'Uso de CPU' "${cpu_usage}%" "$cpu_status"

read -r mem_usage mem_used_mb mem_total_mb <<< "$(get_memory_usage)"
mem_status="$(status_for_percent "$mem_usage" "$MEM_WARN" "$MEM_CRIT")"
print_metric 'Uso de memoria' "${mem_usage}% (${mem_used_mb}/${mem_total_mb} MB)" "$mem_status"

disk_usage="$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')"
disk_usage="${disk_usage:-0}"
disk_status="$(status_for_percent "$disk_usage" "$DISK_WARN" "$DISK_CRIT")"
disk_detail="$(df -hP / 2>/dev/null | awk 'NR==2 {printf "%s usados de %s", $3, $2}')"
print_metric 'Disco raiz (/)' "${disk_usage}% - ${disk_detail:-N/A}" "$disk_status"

load1="$(awk '{print $1}' /proc/loadavg 2>/dev/null || printf '0')"
cpu_count="$(get_cpu_count)"
load_ratio="$(awk -v load_value="$load1" -v cores="$cpu_count" 'BEGIN {if (cores < 1) cores=1; printf "%d", (load_value*100)/cores}')"
if (( load_ratio >= 200 )); then
  load_status='CRITICO'
elif (( load_ratio >= 100 )); then
  load_status='ATENCAO'
else
  load_status='OK'
fi
print_metric 'Carga (1 minuto)' "${load1} para ${cpu_count} CPU(s)" "$load_status"

section 'REDE'
IFS='|' read -r interface local_ip gateway <<< "$(get_network_info)"
print_metric 'Interface principal' "$interface" 'INFO'
print_metric 'Endereco IPv4' "$local_ip" 'INFO'
print_metric 'Gateway padrao' "$gateway" 'INFO'

connectivity="$(check_connectivity)"
case "$connectivity" in
  OK)           print_metric "Conectividade (${CHECK_TARGET})" 'Resposta recebida' 'OK' ;;
  FALHA)        print_metric "Conectividade (${CHECK_TARGET})" 'Sem resposta' 'ATENCAO' ;;
  INDISPONIVEL) print_metric 'Conectividade' 'Comando ping nao encontrado' 'INFO' ;;
esac

section 'SERVICOS'
if command_exists systemctl && systemctl list-units >/dev/null 2>&1; then
  failed_services="$(systemctl --failed --no-legend --plain 2>/dev/null | awk 'NF {count++} END {print count+0}')"
  if (( failed_services > 0 )); then
    print_metric 'Servicos com falha' "$failed_services" 'ATENCAO'
    systemctl --failed --no-legend --plain 2>/dev/null | awk '{printf "  - %s\n", $1}'
  else
    print_metric 'Servicos com falha' '0' 'OK'
  fi
else
  print_metric 'Systemd' 'Nao disponivel neste ambiente' 'INFO'
fi

section 'RESUMO'
case "$OVERALL_STATUS" in
  0)
    printf '%bSTATUS GERAL: SAUDAVEL%b\n' "$BOLD$GREEN" "$RESET"
    ;;
  1)
    printf '%bSTATUS GERAL: ATENCAO NECESSARIA%b\n' "$BOLD$YELLOW" "$RESET"
    ;;
  *)
    printf '%bSTATUS GERAL: CONDICAO CRITICA%b\n' "$BOLD$RED" "$RESET"
    ;;
esac

printf 'Observacao: o script apenas consulta informacoes e nao altera o sistema.\n'
exit "$OVERALL_STATUS"
