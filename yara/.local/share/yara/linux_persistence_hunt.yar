/*
  linux_persistence_hunt.yar

  System-wide Linux hunt rules for suspicious persistence, credential theft,
  shell hijacking, downloader/execution behavior, reverse shells, and common
  user-level persistence mechanisms.

  These are hunt rules. A match means review the file; it is not proof of
  compromise.
*/

rule Linux_Reverse_Shell_Dev_TCP
{
    meta:
        description = "Shell reverse shell using /dev/tcp redirection"
        severity = "high"

    strings:
        $dev_tcp = "/dev/tcp/" nocase
        $bash_i = "bash -i" nocase
        $sh_i   = "sh -i" nocase
        $redir1 = ">&"
        $redir2 = "0<&"
        $execfd = /exec\s+[0-9]+<>\/dev\/tcp\/[A-Za-z0-9._-]{1,253}\/[0-9]{2,5}/ nocase

    condition:
        $execfd or
        (
            $dev_tcp and
            any of ($bash_i, $sh_i) and
            any of ($redir1, $redir2)
        )
}

rule Linux_Reverse_Shell_Netcat_Socat
{
    meta:
        description = "Netcat/ncat/socat reverse shell patterns"
        severity = "high"

    strings:
        $nc_e_1 = /(^|[^A-Za-z0-9_-])nc\s+(-e|-c)\s+\/bin\/(sh|bash)\s+[A-Za-z0-9._-]{1,253}\s+[0-9]{2,5}/ nocase
        $nc_e_2 = /(^|[^A-Za-z0-9_-])ncat\s+([^;\n]{0,120})?(--exec|-e)\s+\/bin\/(sh|bash)/ nocase
        $mkfifo = /mkfifo\s+\/tmp\/[A-Za-z0-9._-]{1,80}[^\n]{0,300}(nc|ncat)\s+[A-Za-z0-9._-]{1,253}\s+[0-9]{2,5}/ nocase
        $socat = /socat\s+[^\n]{0,300}(exec|system):['"]?\/bin\/(sh|bash)[^\n]{0,300}(pty|stderr|setsid|sigint|sane)/ nocase

    condition:
        any of them
}

rule Linux_Download_And_Execute
{
    meta:
        description = "Download piped directly to shell/interpreter"
        severity = "high"

    strings:
        $curl_sh_1 = /curl\s+[^\n|;&]{1,300}\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b/ nocase
        $curl_sh_2 = /curl\s+[^\n]{0,120}\s+-o\s+-\s+[^\n]{0,300}\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b/ nocase
        $wget_sh_1 = /wget\s+[^\n|;&]{1,300}\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b/ nocase
        $wget_sh_2 = /wget\s+[^\n]{0,120}\s+-O\s+-\s+[^\n]{0,300}\|\s*(sudo\s+)?(sh|bash|zsh|ksh)\b/ nocase
        $python_exec_url = /python[0-9.]*\s+-c\s+['"][^\n]{0,300}(urlopen|requests\.get)[^\n]{0,300}exec\s*\(/ nocase
        $perl_exec_url = /perl\s+-M(LWP|HTTP)::[^\n]{0,200}-e\s+['"][^\n]{0,300}system\s*\(/ nocase

    condition:
        any of them
}

rule Linux_Base64_Or_Encoded_Execution
{
    meta:
        description = "Encoded content decoded into shell/eval"
        severity = "high"

    strings:
        $b64_pipe_shell = /base64\s+(-d|--decode)[^\n]{0,160}\|\s*(sh|bash|zsh|ksh)\b/ nocase
        $openssl_pipe_shell = /openssl\s+enc\s+(-base64|-a)\s+-d[^\n]{0,200}\|\s*(sh|bash|zsh|ksh)\b/ nocase
        $eval_b64 = /eval\s+["']?\$\((echo|printf)[^\n]{0,300}base64\s+(-d|--decode)/ nocase
        $echo_b64_decode = /echo\s+['"]?[A-Za-z0-9+\/]{100,}={0,2}['"]?\s*\|\s*base64\s+(-d|--decode)/ nocase
        $python_b64_exec = /python[0-9.]*\s+-c\s+['"][^\n]{0,300}base64\.b64decode[^\n]{0,300}exec\s*\(/ nocase

    condition:
        any of them
}

rule Linux_Suspicious_Eval_Obfuscation
{
    meta:
        description = "Suspicious eval command substitution or escaped payload"
        severity = "medium"

    strings:
        $eval_curl = /eval\s+["']?\$\((curl|wget)\s+/ nocase
        $eval_printf = /eval\s+["']?\$\(printf\s+['"][^'"\n]{40,}/ nocase
        $eval_echo_encoded = /eval\s+["']?\$\(echo\s+['"]?[A-Za-z0-9+\/]{80,}={0,2}/ nocase
        $hex_shell_exec = /(eval|bash|sh)\s+['"]?([^'"\n]{0,80})?(\\x[0-9a-fA-F]{2}){8,}/ nocase

    condition:
        any of them
}

rule Linux_SSH_Key_Exfiltration
{
    meta:
        description = "Potential SSH private key exfiltration"
        severity = "high"

    strings:
        $id_rsa = ".ssh/id_rsa"
        $id_ed25519 = ".ssh/id_ed25519"
        $id_ecdsa = ".ssh/id_ecdsa"
        $net_tool = /(curl|wget|nc|ncat|socat|scp|rsync|ftp|sftp)\b/ nocase

    condition:
        any of ($id_*) and $net_tool
}

rule Linux_Shell_History_Tamper_Or_Exfil
{
    meta:
        description = "History tampering or history exfiltration"
        severity = "medium"

    strings:
        $hist_null = /HISTFILE\s*=\s*\/dev\/null/ nocase
        $hist_unset = /unset\s+HISTFILE/ nocase
        $hist_clear = /history\s+-c\b/ nocase
        $hist_rm = /rm\s+(-f\s+)?[^\n]{0,120}\.(bash|zsh|python)_history/ nocase
        $hist_exfil = /(curl|wget|nc|ncat|socat|scp|rsync)\s+[^\n]{0,300}\.(bash|zsh|python)_history/ nocase

    condition:
        any of them
}

rule Linux_Shell_Command_Hijack
{
    meta:
        description = "Aliases/functions hijacking sensitive commands with network execution"
        severity = "medium"

    strings:
        $alias_sudo = /alias\s+sudo=['"]?[^\n]{0,300}(curl|wget|nc|ncat|socat|bash|sh|python|perl)/ nocase
        $alias_ssh = /alias\s+ssh=['"]?[^\n]{0,300}(curl|wget|nc|ncat|socat|bash|sh|python|perl)/ nocase
        $alias_git = /alias\s+git=['"]?[^\n]{0,300}(curl|wget|nc|ncat|socat|bash|sh|python|perl)/ nocase
        $func_sudo = /(^|\n)sudo\s*\(\)\s*\{[^\n]{0,300}(curl|wget|nc|ncat|socat)/ nocase
        $func_ssh = /(^|\n)ssh\s*\(\)\s*\{[^\n]{0,300}(curl|wget|nc|ncat|socat)/ nocase
        $func_git = /(^|\n)git\s*\(\)\s*\{[^\n]{0,300}(curl|wget|nc|ncat|socat)/ nocase

    condition:
        any of them
}

rule Linux_LD_PRELOAD_Or_PATH_Hijack
{
    meta:
        description = "Potential preload, shell env, or PATH hijack"
        severity = "medium"

    strings:
        $ld_preload_tmp = /LD_PRELOAD\s*=\s*[^;\n]{0,120}\/(tmp|var\/tmp|dev\/shm)\// nocase
        $ld_library_tmp = /LD_LIBRARY_PATH\s*=\s*[^;\n]{0,160}\/(tmp|var\/tmp|dev\/shm)\// nocase
        $bash_env = /BASH_ENV\s*=\s*[^;\n]{1,200}/ nocase
        $env_file = /(^|\s)ENV\s*=\s*[^;\n]{1,200}\.(sh|bash|zsh|ksh)/ nocase
        $path_tmp_front = /PATH\s*=\s*\/(tmp|var\/tmp|dev\/shm)[^;\n]{0,200}/ nocase
        $path_cwd = /PATH\s*=[^;\n]{0,200}(^|:)\.(:|$)/ nocase

    condition:
        any of them
}

rule Linux_Cron_Persistence_Suspicious
{
    meta:
        description = "Suspicious cron persistence"
        severity = "high"

    strings:
        $echo_to_crontab = /echo\s+['"][^\n]{0,300}(curl|wget|bash|sh|python|perl|nc|ncat|socat)[^\n]{0,300}['"]\s*\|\s*crontab\s+-/ nocase
        $at_reboot_net = /@(reboot|hourly|daily)\s+[^\n]{0,300}(curl|wget|bash|sh|python|perl|nc|ncat|socat)/ nocase
        $cron_file_net = /(^|\n)\s*\*\/?[0-9*,-]*\s+\*\/?[0-9*,-]*\s+\*\/?[0-9*,-]*\s+\*\/?[0-9*,-]*\s+\*\/?[0-9*,-]*\s+[^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp)/ nocase

    condition:
        any of them
}

rule Linux_Systemd_User_Persistence_Suspicious
{
    meta:
        description = "Suspicious systemd service persistence"
        severity = "high"

    strings:
        $service = "[Service]"
        $exec_net = /Exec(Start|StartPre|StartPost)\s*=[^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp|base64\s+(-d|--decode))/ nocase
        $systemctl_enable = /systemctl\s+(--user\s+)?enable\s+[A-Za-z0-9_.@-]+/ nocase

    condition:
        ($service and $exec_net) or $systemctl_enable
}

rule Linux_XDG_Autostart_Suspicious
{
    meta:
        description = "Suspicious XDG autostart entry"
        severity = "high"

    strings:
        $desktop_entry = "[Desktop Entry]"
        $type_app = "Type=Application"
        $exec_suspicious = /Exec\s*=[^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp|base64\s+(-d|--decode)|bash\s+-c|sh\s+-c|python[0-9.]*\s+-c|perl\s+-e)/ nocase

    condition:
        $desktop_entry and $type_app and $exec_suspicious
}

rule Linux_Vim_Nvim_Suspicious_Autocmd
{
    meta:
        description = "Suspicious Vim/Neovim autocmd or shell execution"
        severity = "medium"

    strings:
        $autocmd_net = /autocmd\s+[^\n]{0,160}(VimEnter|BufRead|BufWritePost|FileType)[^\n]{0,300}!(curl|wget|nc|ncat|socat|bash|sh|python|perl)/ nocase
        $silent_net = /silent!?\s+!(curl|wget|nc|ncat|socat)[^\n]{0,300}/ nocase
        $lua_execute_net = /os\.execute\s*\(\s*['"][^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp)/ nocase
        $lua_popen_net = /io\.popen\s*\(\s*['"][^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp)/ nocase

    condition:
        any of them
}

rule Linux_Tmux_Suspicious_Hook
{
    meta:
        description = "Suspicious tmux hook or run-shell command"
        severity = "medium"

    strings:
        $run_shell_net = /run-shell\s+['"]?[^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp|base64\s+(-d|--decode)|bash\s+-c|sh\s+-c|python[0-9.]*\s+-c|perl\s+-e)/ nocase
        $hook_net = /set-hook\s+[^\n]{0,200}(client-attached|session-created|pane-focus-in)[^\n]{0,300}(curl|wget|nc|ncat|socat|\/dev\/tcp)/ nocase

    condition:
        any of them
}

rule Linux_Python_Download_Exec
{
    meta:
        description = "Python download and execute behavior"
        severity = "high"

    strings:
        $requests_exec = /exec\s*\([^\n]{0,200}requests\.get\s*\([^\n]{0,300}\)/ nocase
        $urlopen_exec = /exec\s*\([^\n]{0,200}urlopen\s*\([^\n]{0,300}\)/ nocase
        $read_exec = /exec\s*\(\s*open\s*\([^\n]{0,160}\)\.read\s*\(\s*\)/ nocase
        $subproc_shell_net = /subprocess\.(Popen|run|call)\s*\([^\n]{0,300}(curl|wget|nc|ncat|socat)[^\n]{0,300}shell\s*=\s*True/ nocase

    condition:
        any of them
}

rule Linux_Potential_Private_Key_In_User_File
{
    meta:
        description = "Private key material in scanned file"
        severity = "medium"

    strings:
        $openssh = "-----BEGIN OPENSSH PRIVATE KEY-----"
        $rsa = "-----BEGIN RSA PRIVATE KEY-----"
        $ec = "-----BEGIN EC PRIVATE KEY-----"
        $dsa = "-----BEGIN DSA PRIVATE KEY-----"

    condition:
        any of them
}

rule Linux_Common_Token_Leak
{
    meta:
        description = "Common API token or credential-looking string"
        severity = "medium"

    strings:
        $aws_access_key = /AKIA[0-9A-Z]{16}/
        $github_pat = /gh[pousr]_[A-Za-z0-9_]{30,}/
        $slack_token = /xox[baprs]-[A-Za-z0-9-]{20,}/
        $generic_export_secret = /export\s+[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_KEY)[A-Z0-9_]*\s*=\s*['"]?[A-Za-z0-9+\/_=.:@-]{16,}/ nocase
        $generic_assign_secret = /(^|\n)\s*[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_KEY)[A-Z0-9_]*\s*=\s*['"][^'"\n]{16,}['"]/ nocase

    condition:
        any of them
}

rule Linux_Suspicious_Tmp_Execution
{
    meta:
        description = "Execution from common writable temp locations"
        severity = "medium"

    strings:
        $tmp_exec_shell = /(bash|sh|zsh|ksh)\s+\/(tmp|var\/tmp|dev\/shm)\/[A-Za-z0-9._-]{1,120}/ nocase
        $chmod_tmp = /chmod\s+(\+x|[0-7]{3,4})\s+\/(tmp|var\/tmp|dev\/shm)\/[A-Za-z0-9._-]{1,120}/ nocase
        $exec_tmp = /\/(tmp|var\/tmp|dev\/shm)\/[A-Za-z0-9._-]{1,120}\s*(&|;|\n|$)/ nocase

    condition:
        any of them
}

/*
  awesome_yara_linux_triage.yar

  Ultra-light Linux triage bundle derived from the Awesome YARA full bundle.
  Generated: 2026-04-29 08:55:45 PDT
  YARA validation version: 4.5.5

  Intent: practical quick Linux host triage, not exhaustive malware hunting.
  Scope: Linux ELF/rootkits, miners, SSH/backdoor indicators, selected webshells,
  and major server-side exploit artifacts. Broad Windows/APT/evasion/keyword packs
  are intentionally excluded.

  Existing rule files were not modified.

  Included source files: 39 of 4607
  Included rules: 84
*/


// ===== BEGIN SOURCE: github:advanced-threat-research/Yara-Rules:master:miners/MINER_Monero.yar | rules: 1 =====
rule MINER_monero_mining_detection {

   meta:

      description = "Monero mining software"
      author = "Trellix ATR team"
      date = "2018-04-05"
      rule_version = "v1"
      malware_type = "miner"
      malware_family = "Ransom:W32/MoneroMiner"
      actor_type = "Cybercrime"
      actor_group = "Unknown"   
      
   strings:

      $1 = "* COMMANDS:     'h' hashrate, 'p' pause, 'r' resume" fullword ascii
      $2 = "--cpu-affinity       set process affinity to CPU core(s), mask 0x3 for cores 0 and 1" fullword ascii
      $3 = "* THREADS:      %d, %s, av=%d, %sdonate=%d%%%s" fullword ascii
      $4 = "--user-agent         set custom user-agent string for pool" fullword ascii
      $5 = "-O, --userpass=U:P       username:password pair for mining server" fullword ascii
      $6 = "--cpu-priority       set process priority (0 idle, 2 normal to 5 highest)" fullword ascii
      $7 = "-p, --pass=PASSWORD      password for mining server" fullword ascii
      $8 = "* VERSIONS:     XMRig/%s libuv/%s%s" fullword ascii
      $9 = "-k, --keepalive          send keepalived for prevent timeout (need pool support)" fullword ascii
      $10 = "--max-cpu-usage=N    maximum CPU usage for automatic threads mode (default 75)" fullword ascii
      $11 = "--nicehash           enable nicehash/xmrig-proxy support" fullword ascii
      $12 = "<!--The ID below indicates application support for Windows 10 -->" fullword ascii
      $13 = "* CPU:          %s (%d) %sx64 %sAES-NI" fullword ascii
      $14 = "-r, --retries=N          number of times to retry before switch to backup server (default: 5)" fullword ascii
      $15 = "-B, --background         run the miner in the background" fullword ascii
      $16 = "* API PORT:     %d" fullword ascii
      $17 = "--api-access-token=T access token for API" fullword ascii
      $18 = "-t, --threads=N          number of miner threads" fullword ascii
      $19 = "--print-time=N       print hashrate report every N seconds" fullword ascii
      $20 = "-u, --user=USERNAME      username for mining server" fullword ascii
   
   condition:
   
      ( uint16(0) == 0x5a4d and
      filesize < 4000KB and
      ( 8 of them )) or
      ( all of them )
}
// ===== END SOURCE: github:advanced-threat-research/Yara-Rules:master:miners/MINER_Monero.yar =====

// ===== BEGIN SOURCE: github:advanced-threat-research/Yara-Rules:master:miners/Trojan_CoinMiner.yar | rules: 1 =====
import "pe"

rule Trojan_CoinMiner {
   meta:
      description = "Rule to detect Coinminer malware"
      author = "Trellix ATR"
      date = "2021-07-22"
      version = "v1"
      hash1 = "3bdac08131ba5138bcb5abaf781d6dc7421272ce926bc37fa27ca3eeddcec3c2"
      hash2 = "d60766c4e6e77de0818e59f687810f54a4e08505561a6bcc93c4180adb0f67e7"
   
   strings:
  
      $seq0 = { df 75 ab 7b 80 bf 83 c1 48 b3 18 74 70 01 24 5c }
      $seq1 = { 08 37 4e 6e 0f 50 0b 11 d0 98 0f a8 b8 27 47 4e }
      $seq2 = { bf 17 5a 08 09 ab 80 2f a1 b0 b1 da 47 9f e1 61 }
      $seq3 = { 53 36 34 b2 94 01 cc 05 8c 36 aa 8a 07 ff 06 1f }
      $seq4 = { 25 30 ae c4 44 d1 97 82 a5 06 05 63 07 02 28 3a }
      $seq5 = { 01 69 8e 1c 39 7b 11 56 38 0f 43 c8 5f a8 62 d0 }
   condition:
      ( uint16(0) == 0x5a4d and filesize < 5000KB and pe.imphash() == "e4290fa6afc89d56616f34ebbd0b1f2c" and 3 of ($seq*)
      ) 
}
// ===== END SOURCE: github:advanced-threat-research/Yara-Rules:master:miners/Trojan_CoinMiner.yar =====

// ===== BEGIN SOURCE: github:advanced-threat-research/Yara-Rules:master:ransomware/RANSOM_Linux_HelloKitty0721.yar | rules: 1 =====
rule ransom_Linux_HelloKitty_0721 {
   meta:
      description = "rule to detect Linux variant of the Hello Kitty Ransomware"
      author = "Christiaan @ ATR"
      date = "2021-07-19"
      Rule_Version = "v1"
      malware_type = "ransomware"
      malware_family = "Ransom:Linux/HelloKitty"
      hash1 = "ca607e431062ee49a21d69d722750e5edbd8ffabcb54fa92b231814101756041"
      hash2 = "556e5cb5e4e77678110961c8d9260a726a363e00bf8d278e5302cb4bfccc3eed"

   strings:
      $v1 = "esxcli vm process kill -t=force -w=%d" fullword ascii
      $v2 = "esxcli vm process kill -t=hard -w=%d" fullword ascii
      $v3 = "esxcli vm process kill -t=soft -w=%d" fullword ascii
      $v4 = "error encrypt: %s rename back:%s" fullword ascii
      $v5 = "esxcli vm process list" fullword ascii
      $v6 = "Total VM run on host:" fullword ascii
      $v7 = "error lock_exclusively:%s owner pid:%d" fullword ascii
      $v8 = "Error open %s in try_lock_exclusively" fullword ascii
      $v9 = "Mode:%d  Verbose:%d Daemon:%d AESNI:%d RDRAND:%d " fullword ascii
      $v10 = "pthread_cond_signal() error" fullword ascii
      $v11 = "ChaCha20 for x86_64, CRYPTOGAMS by <appro@openssl.org>" fullword ascii

   condition:
      ( uint16(0) == 0x457f and filesize < 200KB and ( 8 of them )
      ) or ( all of them )
}
// ===== END SOURCE: github:advanced-threat-research/Yara-Rules:master:ransomware/RANSOM_Linux_HelloKitty0721.yar =====

// ===== BEGIN SOURCE: github:bartblaze/Yara-rules:master:rules/generic/Webshell_in_image.yar | rules: 1 =====
rule Webshell_in_image
{
    meta:
        id = "6IgdjyQO28avrjCjsw4VWh"
        fingerprint = "459e953dedb3a743094868b6ba551e72c3640e3f4d2d2837913e4288e88f6eca"
        version = "1.0"
        creation_date = "2020-01-01"
        first_imported = "2021-12-30"
        last_modified = "2025-02-14"
        status = "RELEASED"
        sharing = "TLP:CLEAR"
        source = "BARTBLAZE"
        author = "@bartblaze"
        description = "Identifies a webshell or backdoor in image files."
        category = "MALWARE"
        malware_type = "WEBSHELL"

    strings:
        $gif = {47 49 46 38 3? 61}
        $png = {89 50 4E 47 0D 0A 1A 0A}
        $jpeg = {FF D8 FF E0}
        $bmp = {42 4D}
        $s1 = "<%@ Page Language=" ascii wide
        $s2 = /<\?php[ -~]{30,}/ ascii wide nocase
        $s3 = /eval\([ -~]{30,}/ ascii wide nocase
        $s4 = /<eval[ -~]{30,}/ ascii wide nocase
        $s5 = /<%eval[ -~]{30,}/ ascii wide nocase

    condition:
        ($gif at 0 and any of ($s*)) or ($png at 0 and any of ($s*)) or ($jpeg at 0 and any of ($s*)) or ($bmp at 0 and any of ($s*))
}
// ===== END SOURCE: github:bartblaze/Yara-rules:master:rules/generic/Webshell_in_image.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_lnx_linadoor_rootkit.yar | rules: 1 =====
rule MAL_LNX_LinaDoor_Rootkit_May22 {
   meta:
      description = "Detects LinaDoor Linux Rootkit"
      author = "Florian Roth"
      reference = "Internal Research"
      date = "2022-05-19"
      modified = "2023-05-16"
      score = 85
      hash1 = "25ff1efe36eb15f8e19411886217d4c9ec30b42dca072b1bf22f041a04049cd9"
      hash2 = "4792e22d4c9996af1cb58ed54fee921a7a9fdd19f7a5e7f268b6793cdd1ab4e7"
      hash3 = "9067230a0be61347c0cf5c676580fc4f7c8580fc87c932078ad0c3f425300fb7"
      hash4 = "940b79dc25d1988dabd643e879d18e5e47e25d0bb61c1f382f9c7a6c545bfcff"
      hash5 = "a1df5b7e4181c8c1c39de976bbf6601a91cde23134deda25703bc6d9cb499044"
      hash6 = "c4eea99658cd82d48aaddaec4781ce0c893de42b33376b6c60a949008a3efb27"
      hash7 = "c5651add0c7db3bbfe0bbffe4eafe9cd5aa254d99be7e3404a2054d6e07d20e7"
      id = "e2f250b4-9a8a-5d70-83d7-5d12ad3763fb"
   strings:
      $s1 = "/dev/net/.../rootkit_/" ascii
      $s2 = "did_exec" ascii fullword
      $s3 = "rh_reserved_tp_target" ascii fullword
      $s4 = "HIDDEN_SERVICES" ascii fullword
      $s5 = "bypass_udp_ports" ascii fullword
      $s6 = "DoBypassIP" ascii fullword

      $op1 = { 74 2a 4c 89 ef e8 00 00 00 00 48 89 da 4c 29 e2 48 01 c2 31 c0 4c 39 f2 }
      $op2 = { e8 00 00 00 00 48 89 da 4c 29 e2 48 01 c2 31 c0 4c 39 f2 48 0f 46 c3 5b }
      $op3 = { 48 89 c3 74 2a 4c 89 ef e8 00 00 00 00 48 89 da 4c 29 e2 48 01 c2 31 c0 }
      $op4 = { 4c 29 e2 48 01 c2 31 c0 4c 39 f2 48 0f 46 c3 5b 41 5c 41 5d }

      $fp1 = "/wgsyncdaemon.pid"
   condition:
      uint16(0) == 0x457f and
      filesize < 2000KB and 2 of them 
      and not 1 of ($fp*)
      or 4 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_lnx_linadoor_rootkit.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_mal_ilo_board_elf.yar | rules: 1 =====
rule APT_MAL_HP_iLO_Firmware_Dec21_1 {
   meta:
      description = "Detects suspicios ELF files with sections as described in malicious iLO Board analysis by AmnPardaz in December 2021"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://threats.amnpardaz.com/en/2021/12/28/implant-arm-ilobleed-a/"
      date = "2021-12-28"
      score = 80
      id = "7f5fa905-07a3-55da-b644-c5ab882b4a9d"
   strings:
      $s1 = ".newelf.elf.text" ascii
      $s2 = ".newelf.elf.libc.so.data" ascii
      $s3 = ".newelf.elf.Initial.stack" ascii
      $s4 = ".newelf.elf.libevlog.so.data" ascii
   condition:
      filesize < 5MB and 2 of them or 
      all of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_mal_ilo_board_elf.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_sandworm_exim_expl.yar | rules: 9 =====
rule APT_Sandworm_Keywords_May20_1 {
   meta:
      description = "Detects commands used by Sandworm group to exploit critical vulernability CVE-2019-10149 in Exim"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      id = "e0d4e90e-5547-5487-8d0c-a141d88fff7c"
   strings:
      $x1 = "MAIL FROM:<$(run("
      $x2 = "exec\\x20\\x2Fusr\\x2Fbin\\x2Fwget\\x20\\x2DO\\x20\\x2D\\x20http"
   condition:
      filesize < 8000KB and
      1 of them
}

rule APT_Sandworm_SSH_Key_May20_1 {
   meta:
      description = "Detects SSH key used by Sandworm on exploited machines"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "ea2968b8-7ae4-56b8-9547-816c5e37c50a"
   strings:
      $x1 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2q/NGN/brzNfJiIp2zswtL33tr74pIAjMeWtXN1p5Hqp5fTp058U1EN4NmgmjX0KzNjjV"
   condition:
      filesize < 1000KB and
      1 of them
}

rule APT_Sandworm_SSHD_Config_Modification_May20_1 {
   meta:
      description = "Detects ssh config entry inserted by Sandworm on compromised machines"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "dd60eeb7-3d4b-5a6a-8054-50c617ee8c73"
   strings:     
      $x1 = "AllowUsers mysql_db" ascii

      $a1 = "ListenAddress" ascii fullword
   condition:
      filesize < 10KB and
      all of them
}

rule APT_Sandworm_InitFile_May20_1 {
   meta:
      description = "Detects mysql init script used by Sandworm on compromised machines"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "0bd613e3-6bd4-5cec-bc0d-2bdb83caf142"
   strings:     
      $s1 = "GRANT ALL PRIVILEGES ON * . * TO 'mysqldb'@'localhost';" ascii
      $s2 = "CREATE USER 'mysqldb'@'localhost' IDENTIFIED BY '" ascii fullword
   condition:
      filesize < 10KB and
      all of them
}

rule APT_Sandworm_User_May20_1 {
   meta:
      description = "Detects user added by Sandworm on compromised machines"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "ada549a4-abcc-5c0a-9601-75631e78c835"
   strings:     
      $s1 = "mysql_db:x:" ascii /* malicious user */

      $a1 = "root:x:"
      $a2 = "daemon:x:"
   condition:
      filesize < 4KB and all of them
}

rule APT_WEBSHELL_PHP_Sandworm_May20_1 {
   meta:
      description = "Detects GIF header PHP webshell used by Sandworm on compromised machines"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "b9ec02c2-fa83-5f21-95cf-3528047b2d01"
   strings:     
      $h1 = "GIF89a <?php $" ascii
      $s1 = "str_replace(" ascii
   condition:
      filesize < 10KB and
      $h1 at 0 and $s1
}

rule APT_SH_Sandworm_Shell_Script_May20_1 {
   meta:
      description = "Detects shell script used by Sandworm in attack against Exim mail server"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://media.defense.gov/2020/May/28/2002306626/-1/-1/0/CSA%20Sandworm%20Actors%20Exploiting%20Vulnerability%20in%20Exim%20Transfer%20Agent%2020200528.pdf"
      date = "2020-05-28"
      hash1 = "dc074464e50502459038ac127b50b8c68ed52817a61c2f97f0add33447c8f730"
      hash2 = "538d713cb47a6b5ec6a3416404e0fc1ebcbc219a127315529f519f936420c80e"
      id = "21cf2c89-5511-5eb6-a2dd-4ad54ebfa2d1"
   strings:     
      $x1 = "echo \"GRANT ALL PRIVILEGES ON * . * TO 'mysqldb'@'localhost';\" >> init-file.txt" ascii fullword
      $x2 = "import base64,sys;exec(base64.b64decode({2:str,3:lambda b:bytes(b,'UTF-8')}[sys.version" ascii fullword
      $x3 = "sed -i -e '/PasswordAuthentication/s/no/yes/g; /PermitRootLogin/s/no/yes/g;" ascii fullword
      $x4 = "useradd -M -l -g root -G root -b /root -u 0 -o mysql_db" ascii fullword
      
      $s1 = "/ip.php?port=${PORT}\"" ascii fullword
      $s2 = "sed -i -e '/PasswordAuthentication" ascii fullword
      $s3 = "PATH_KEY=/root/.ssh/authorized_keys" ascii fullword
      $s4 = "CREATE USER" ascii fullword
      $s5 = "crontab -l | { cat; echo" ascii fullword
      $s6 = "mysqld --user=mysql --init-file=/etc/opt/init-file.txt --console" ascii fullword
      $s7 = "sshkey.php" ascii fullword
   condition:
      uint16(0) == 0x2123 and
      filesize < 20KB and
      1 of ($x*) or 4 of them
}

rule APT_RU_Sandworm_PY_May20_1 {
   meta:
      description = "Detects Sandworm Python loader"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/billyleonard/status/1266054881225236482"
      date = "2020-05-28"
      hash1 = "c025008463fdbf44b2f845f2d82702805d931771aea4b506573b83c8f58bccca"
      id = "a392d800-1fe8-5ae9-b813-e1dfcedecda6"
   strings:
      $x1 = "o.addheaders=[('User-Agent','Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko')]" ascii fullword
      
      $s1 = "exec(o.open('http://" ascii
      $s2 = "__import__({2:'urllib2',3:'urllib.request'}"
   condition:
      uint16(0) == 0x6d69 and
      filesize < 1KB and
      1 of ($x*) or 2 of them
}

rule APT_RU_Sandworm_PY_May20_2 {
   meta:
      description = "Detects Sandworm Python loader"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/billyleonard/status/1266054881225236482"
      date = "2020-05-28"
      hash1 = "abfa83cf54db8fa548942acd845b4f34acc94c46d4e1fb5ce7e97cc0c6596676"
      id = "5b32ad64-d959-5632-a03c-17aa055b213f"
   strings:
      $x1 = "import sys;import re, subprocess;cmd" ascii fullword
      $x2 = "UA='Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko';server='http"
      $x3 = "';t='/admin/get.php';req" ascii
      $x4 = "ps -ef | grep Little\\ Snitch | grep " ascii fullword
   condition:
      uint16(0) == 0x6d69 and
      filesize < 2KB and
      1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_sandworm_exim_expl.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_triton_mal_sshdoor.yar | rules: 2 =====
// For feedback or questions contact us at: github@eset.com
// https://github.com/eset/malware-ioc/
//
// These yara rules are provided to the community under the two-clause BSD
// license as follows:
//
// Copyright (c) 2018, ESET
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

// MODIFIED VERSION
// Mofificaton applied by Florian Roth 05.12.2018
// Reasons for the changes:
//    - Cleaner rule structure (no inter-dependencies)
//    - Performance
//    - Limited rules to ELF files to reduce false positive rate
// Disadvantage:
//    - Lost family identification (see the original rules)
//    - Missing rule (the one with the expected & relevant performance impact)

rule MAL_LNX_SSHDOOR_Triton {
   meta:
      description = "Signature detecting "
      author = "Marc-Etienne M.Leveille, modified by Florian Roth"
      email  = "leveille@eset.com"
      reference = "https://www.welivesecurity.com/wp-content/uploads/2018/12/ESET-The_Dark_Side_of_the_ForSSHe.pdf"
      date = "2018-12-05"
      license = "BSD 2-Clause"
      id = "51ec2e60-d84a-5271-a7fe-e12d597be00c"
   strings:
      /* SSH binaries - specific strings */
      $a_usage1 = "usage: ssh ["
      $a_usage2 = "usage: %s [options] [command [arg ...]]"
      $a_old_version1 = "-L listen-port:host:port"
      $a_old_version2 = "Listen on the specified port (default: 22)"
      $a_usage = "usage: %s [-46Hv] [-f file] [-p port] [-T timeout] [-t type]"
      /* SSH binaries - combo required */
      $ac_usage = "usage: %s [options] [file ...]\n"
      $ac_log1 = "Could not open a connection to your authentication agent.\n"
      $ac_pass2 = "Enter your OpenSSH passphrase:"
      $ac_log2 = "Could not grab %s. A malicious client may be eavesdropping on you"
      $ac_pass3 = "Enter new passphrase (empty for no passphrase):"
      $ac_log3 = "revoking certificates by key ID requires specification of a CA key"

      /* Strings from malicious files */
      /* abafar */
      $s_log_c =  "%s:%s@%s"
      $s_log_d =  "%s:%s from %s"
      /* akiva */
      $s_log_aki = /(To|From):\s(%s\s\-\s)?%s:%s\n/
      /* alderaan */
      $s_log_ald = /login\s(in|at):\s(%s\s)?%s:%s\n/
      /* ando */
      $ando_s1 = "%s:%s\n"
      $ando_s2 = "HISTFILE"
      $ando_i = "fopen64"
      $ando_m1 = "cat "
      $ando_m2 = "mail -s"
      /* anoat */
      $s_log_ano = "%s at: %s | user: %s, pass: %s\n"
      /* batuu */
      $s_args_bat = "ssh: ~(av[%d]: %s\n)"
      $s_log_bat = "readpass: %s\n"
      /* banodan */
      $s_banodan1 = "g_server"
      $s_banodan2 = "mine.sock"
      $s_banodan3 = "tspeed"
      $s_banodan4 = "6106#x=%d#%s#%s#speed=%s"
      $s_banodan5 = "usmars.mynetgear.com"
      $s_banodan6 = "user=%s#os=%s#eip=%s#cpu=%s#mem=%s"
      /* borleias */
      $s_borleias_log = "%Y-%m-%d %H:%M:%S [%s]"
      /* ondaron */
      $s_daemon = "user:password --> %s:%s\n"
      $s_client = /user(,|:)(a,)?password@host \-\-> %s(,|:)(b,)?%s@%s\n/
      /* polis_massa */
      $s_polis_log = /\b\w+(:|\s-+>)\s%s(:%d)?\s\t(\w+)?:\s%s\s\t(\w+)?:\s%s/
      /* quarren */
      $s_quarren_log = "h: %s, u: %s, p: %s\n"

      /* chandrilla */
      $chandrila_log = "S%s %s:%s"
      $chandrila_magic = { 05 71 92 7D }

      /* atollon */
      // single byte offset from base pointer
      $atollon_bp = /(\xC6\x45.{2}){25}/
      // dword ss with single byte offset from base pointer
      $atollon_bp_dw = /(\xC7\x45.{5}){20}/
      // 4-bytes offset from base pointer
      $atollon_bp_off = /(\xC6\x85.{5}){25}/
      // single byte offset from stack pointer
      $atollon_sp = /(\xC6\x44\x24.{2}){25}/
      // 4-bytes offset from stack pointer
      $atollon_sp_off = /(\xC6\x84\x24.{5}){25}/
      /* other strings */
      $atollon_f1 = "PEM_read_RSA_PUBKEY"
      $atollon_f2 = "RAND_add"
      $atollon_log = "%s:%s"
      $atollon_rand = "/dev/urandom"

      /* bespin */
      $bespin_log1 = "%Y-%m-%d %H:%M:%S"
      $bespin_log2 = "%s %s%s"
      $bespin_log3 = "[%s]"

      /* coruscant */
      $coruscant_s1 = "%s:%s@%s\n"
      $coruscant_s2 = "POST"
      $coruscant_s3 = "HTTP/1.1"

      /* crait */
      $crait_i1 = "flock"
      $crait_i2 = "fchmod"
      $crait_i3 = "sendto"

      /* jakuu */
      $jakuu_dec = /GET\s\/\?(s|c)id=/
      $jakuu_enc1 = "getifaddrs"
      $jakuu_enc2 = "usleep"
      $jakuu_ns = "gethostbyname"
      $jakuu_log = "%s:%s"
      $jakuu_rc4 = { A1 71 31 17 11 1A 22 27 55 00 66 A3 10 FE C2 10 22 32 6E 95 90 84 F9 11 73 62 95 5F 4D 3B DB DC }

      /* kamino */
      $kamino_s1 = "/var/log/wtmp"
      $kamino_s2 = "/var/log/secure"
      $kamino_s3 = "/var/log/auth.log"
      $kamino_s4 = "/var/log/messages"
      $kamino_s5 = "/var/log/audit/audit.log"
      $kamino_s6 = "/var/log/httpd-access.log"
      $kamino_s7 = "/var/log/httpd-error.log"
      $kamino_s8 = "/var/log/xferlog"
      $kamino_i1 = "BIO_f_base64"
      $kamino_i2 = "PEM_read_bio_RSA_PUBKEY"
      $kamino_i3 = "srand"
      $kamino_i4 = "gethostbyname"

      /* kessel */
      $kessel_rc4 = "Xee5chu1Ohshasheed1u"
      $kessel_s1 = "ssh:%s:%s:%s:%s"
      $kessel_s2 = "sshkey:%s:%s:%s:%s:%s"
      $kessel_s3 = "sshd:%s:%s"
      $kessel_i1 = "spy_report"
      $kessel_i2 = "protoShellCMD"
      $kessel_i3 = "protoUploadFile"
      $kessel_i4 = "protoSendReport"
      $kessel_i5 = "tunRecvDNS"
      $kessel_i6 = "tunPackMSG"

      /* mimban */
      $mimban_s1 = "<|||%s|||%s|||%d|||>"
      $mimban_s2 = />\|\|\|%s\|\|\|%s\|\|\|\d\|\|\|%s\|\|\|%s\|\|\|%s\|\|\|%s\|\|\|</
      $mimban_s3 = "-----BEGIN PUBLIC KEY-----"
      $mimban_i1 = "BIO_f_base64"
      $mimban_i2 = "PEM_read_bio_RSA_PUBKEY"
      $mimban_i3 = "gethostbyname"
   condition:
      uint32be(0) == 0x7f454c46 and // ELF
      ( 1 of ($a_*) or 2 of ($ac_*) ) // SSH Binary
      and (
         ( 1 of ($s*) ) or
         ( all of ($ando_s*) and ($ando_i or all of ($ando_m*)) ) or
         ( all of ($atollon*) ) or
         ( all of ($bespin*) ) or
         ( all of ($chandrila*) ) or
         ( all of ($coruscant*) ) or
         ( 2 of ($crait*) ) or
         ( $jakuu_log and $jakuu_ns and ($jakuu_dec or all of ($jakuu_enc*) or $jakuu_rc4)) or
         ( 5 of ($kamino_s*) and 3 of ($kamino_i*) ) or
         ( 2 of ($kessel_s*) or 2 of ($kessel_i*) or $kessel_rc4 ) or
         ( 2 of ($mimban_s*) and 2 of ($mimban_i*) )
      )
}

/*
rule endor {
    meta:
        description = "Rule to detect Endor family"
        author = "Hugo Porcher"
        email  = "hugo.porcher@eset.com"
        reference = "https://www.welivesecurity.com/wp-content/uploads/2018/12/ESET-The_Dark_Side_of_the_ForSSHe.pdf"
        date = "2018-12-05"
        license = "BSD 2-Clause"

    strings:
        $u = "user: %s"
        $p = "password: %s"

    condition:
        ssh_binary and $u and $p in (@u..@u+20)
}
*/
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_triton_mal_sshdoor.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_unc2891_tinyshell_slapstick.yar | rules: 3 =====
rule EXT_HKTL_MAL_TinyShell_Backdoor {
   meta:
      author = "Mandiant"
      description = "Detects Tiny Shell - an open-source UNIX backdoor"
      date = "2022-03-17"
      reference = "https://www.mandiant.com/resources/blog/unc2891-overview"
      score = 80
      hash1 = "1f889871263bd6cdad8f3d4d5fc58b4a32669b944d3ed0860730374bb87d730a"
   strings:
      $sb1 = { C6 00 48 C6 4? ?? 49 C6 4? ?? 49 C6 4? ?? 4C C6 4? ?? 53 C6 4? ?? 45 C6 4? ?? 54 C6 4? ?? 3D C6 4? ?? 46 C6 4? ?? 00 }
      $sb2 = { C6 00 54 C6 4? ?? 4D C6 4? ?? 45 C6 4? ?? 3D C6 4? ?? 52 }
      $ss1 = "fork" ascii fullword wide
      $ss2 = "socket" ascii fullword wide
      $ss3 = "bind" ascii fullword wide
      $ss4 = "listen" ascii fullword wide
      $ss5 = "accept" ascii fullword wide
      $ss6 = "alarm" ascii fullword wide
      $ss7 = "shutdown" ascii fullword wide
      $ss8 = "creat" ascii fullword wide
      $ss9 = "write" ascii fullword wide
      $ss10 = "open" ascii fullword wide
      $ss11 = "read" ascii fullword wide
      $ss12 = "execl" ascii fullword wide
      $ss13 = "gethostbyname" ascii fullword wide
      $ss14 = "connect" ascii fullword wide
   condition:
      uint32(0) == 0x464c457f and 1 of ($sb*) and 10 of ($ss*)
}

rule EXT_HKTL_MAL_TinyShell_Backdoor_SPARC {
   meta:
      author = "Mandiant"
      description = "Detects Tiny Shell variant for SPARC - an open-source UNIX backdoor"
      date = "2022-03-17"
      reference = "https://www.mandiant.com/resources/blog/unc2891-overview"
      score = 80
   strings:
      $sb_xor_1 = { DA 0A 80 0C 82 18 40 0D C2 2A 00 0B 96 02 E0 01 98 03 20 01 82 1B 20 04 80 A0 00 01 82 60 20 00 98 0B 00 01 C2 4A 00 0B 80 A0 60 00 32 BF FF F5 C2 0A 00 0B 81 C3 E0 08 }
      $sb_xor_2 = { C6 4A 00 00 80 A0 E0 00 02 40 00 0B C8 0A 00 00 85 38 60 00 C4 09 40 02 84 18 80 04 C4 2A 00 00 82 00 60 01 80 A0 60 04 83 64 60 00 10 6F FF F5 90 02 20 01 81 C3 E0 08 }
   condition:
      uint32(0) == 0x464C457F and (uint16(0x10) & 0x0200 == 0x0200) and (uint16(0x12) & 0x0200 == 0x0200) and 1 of them
}

rule EXT_APT_UNC2891_SLAPSTICK {
   meta:
      author = "Mandiant"
      description = "Detects SLAPSTICK malware used by UNC2891"
      date = "2022-03-17"
      reference = "https://www.mandiant.com/resources/blog/unc2891-overview"
      score = 80
   strings:
      $ss1 = { 25 59 20 25 62 20 25 64 20 25 48 3a 25 4d 3a 25 53 20 20 20 20 00 }
      $ss2 = { 25 2d 32 33 73 20 25 2d 32 33 73 20 25 2d 32 33 73 00 }
      $ss3 = { 25 2d 32 33 73 20 25 2d 32 33 73 20 25 2d 32 33 73 20 25 2d 32 33 73 20 25 2d 32 33 73 20 25 73 0a 00 }
   condition:
      (uint32(0) == 0x464c457f) and all of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_unc2891_tinyshell_slapstick.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_venom_linux_rootkit.yar | rules: 1 =====
/*
   Yara Rule Set
   Author: Florian Roth
   Date: 2017-01-10
   Identifier: Venom Rootkit
*/

/* Rule Set ----------------------------------------------------------------- */

rule Venom_Rootkit {
   meta:
      description = "Venom Linux Rootkit"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://security.web.cern.ch/security/venom.shtml"
      date = "2017-01-12"
      id = "fedc6fa9-7dfb-5e54-a7bf-9a16f96d6886"
   strings:
      $s1 = "%%VENOM%CTRL%MODE%%" ascii fullword
      $s2 = "%%VENOM%OK%OK%%" ascii fullword
      $s3 = "%%VENOM%WIN%WN%%" ascii fullword
      $s4 = "%%VENOM%AUTHENTICATE%%" ascii fullword
      $s5 = ". entering interactive shell" ascii fullword
      $s6 = ". processing ltun request" ascii fullword
      $s7 = ". processing rtun request" ascii fullword
      $s8 = ". processing get request" ascii fullword
      $s9 = ". processing put request" ascii fullword
      $s10 = "venom by mouzone" ascii fullword
      $s11 = "justCANTbeSTOPPED" ascii fullword
   condition:
      filesize < 4000KB and 2 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_venom_linux_rootkit.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_webshell_chinachopper.yar | rules: 1 =====
rule ChinaChopper_Generic {
	meta:
		description = "China Chopper Webshells - PHP and ASPX"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Florian Roth (Nextron Systems)"
		reference = "https://www.fireeye.com/content/dam/legacy/resources/pdfs/fireeye-china-chopper-report.pdf"
		date = "2015/03/10"
		modified = "2022-10-27"
		id = "2473cef1-88cf-5b76-a87a-2978e6780b4f"
	strings:
		$x_aspx = /%@\sPage\sLanguage=.Jscript.%><%eval\(Request\.Item\[.{,100}unsafe/
		$x_php = /<?php.\@eval\(\$_POST./

		$fp1 = "GET /"
		$fp2 = "POST /"
	condition:
		filesize < 300KB and 1 of ($x*) and not 1 of ($fp*)
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_webshell_chinachopper.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/apt_winnti_linux.yar | rules: 2 =====
rule APT_MAL_WinntiLinux_Dropper_AzazelFork_May19 : azazel_fork {
    meta:
        description = "Detection of Linux variant of Winnti"
        author = "Silas Cutler (havex [@] chronicle.security), Chronicle Security"
        version = "1.0"
        date = "2019-05-15"
        TLP = "White"
        sha256 = "4741c2884d1ca3a40dadd3f3f61cb95a59b11f99a0f980dbadc663b85eb77a2a"
        id = "d641de9a-e563-5067-b7e4-0aa83a087ed4"
    strings:
        $config_decr = { 48 89 45 F0 C7 45 EC 08 01 00 00 C7 45 FC 28 00 00 00 EB 31 8B 45 FC 48 63 D0 48 8B 45 F0 48 01 C2 8B 45 FC 48 63 C8 48 8B 45 F0 48 01 C8 0F B6 00 89 C1 8B 45 F8 89 C6 8B 45 FC 01 F0 31 C8 88 02 83 45 FC 01 }
        $export1 = "our_sockets"
        $export2 = "get_our_pids"
    condition:
        uint16(0) == 0x457f and all of them
}

rule APT_MAL_WinntiLinux_Main_AzazelFork_May19 {
    meta:
        description = "Detection of Linux variant of Winnti"
        author = "Silas Cutler (havex [@] chronicle.security), Chronicle Security"
        version = "1.0"
        date = "2019-05-15"
        TLP = "White"
        sha256 = "ae9d6848f33644795a0cc3928a76ea194b99da3c10f802db22034d9f695a0c23"
        id = "a1693e2d-4d89-5cc7-ab14-c8feb000638a"
    strings:
        $uuid_lookup = "/usr/sbin/dmidecode  | grep -i 'UUID' |cut -d' ' -f2 2>/dev/null"
        $dbg_msg = "[advNetSrv] can not create a PF_INET socket"
        $rtti_name1 = "CNetBase"
        $rtti_name2 = "CMyEngineNetEvent"
        $rtti_name3 = "CBufferCache"
        $rtti_name4 = "CSocks5Base"
        $rtti_name5 = "CDataEngine"
        $rtti_name6 = "CSocks5Mgr"
        $rtti_name7 = "CRemoteMsg"
    condition:
        uint16(0) == 0x457f and ( ($dbg_msg and 1 of ($rtti*)) or (5 of ($rtti*)) or ($uuid_lookup and 2 of ($rtti*)) )
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/apt_winnti_linux.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/crime_crypto_miner.yar | rules: 2 =====
rule SUSP_LNX_SH_CryptoMiner_Indicators_Dec20_1 {
   meta:
      description = "Detects helper script used in a crypto miner campaign"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://www.intezer.com/blog/research/new-golang-worm-drops-xmrig-miner-on-servers/"
      date = "2020-12-31"
      hash1 = "3298dbd985c341d57e3219e80839ec5028585d0b0a737c994363443f4439d7a5"
      id = "e376e0e1-1490-5ad4-8ca2-d28ca1c0b51a"
   strings:
      $x1 = "miner running" fullword ascii
      $x2 = "miner runing" fullword ascii
      $x3 = " --donate-level 1 "
      $x4 = " -o pool.minexmr.com:5555 " ascii
   condition:
      filesize < 20KB and 1 of them
}

rule PUA_WIN_XMRIG_CryptoCoin_Miner_Dec20 {
   meta:
      description = "Detects XMRIG crypto coin miners"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://www.intezer.com/blog/research/new-golang-worm-drops-xmrig-miner-on-servers/"
      date = "2020-12-31"
      hash1 = "b6154d25b3aa3098f2cee790f5de5a727fc3549865a7aa2196579fe39a86de09"
      id = "4dfb04e9-fbba-5a6f-ad20-d805025d2d74"
   strings:
      $x1 = "xmrig.exe" fullword wide
      $x2 = "xmrig.com" fullword wide
      $x3 = "* for x86, CRYPTOGAMS" fullword ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 6000KB and 2 of them or all of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/crime_crypto_miner.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/crime_h2miner_kinsing.yar | rules: 1 =====
rule crime_h2miner_kinsing
{
    meta:
        description = "Rule to find Kinsing malware"
        author = "Tony Lambert, Red Canary"
        date = "2020-06-09"
        id = "1cabca0d-7134-517e-b82e-f2b20b4d1c34"
    strings:
        $s1 = "-iL $INPUT --rate $RATE -p$PORT -oL $OUTPUT"
        $s2 = "libpcap"
        $s3 = "main.backconnect"
        $s4 = "main.masscan"
        $s5 = "main.checkHealth"
        $s6 = "main.redisBrute"
        $s7 = "ActiveC2CUrl"
        $s8 = "main.RC4"
        $s9 = "main.runTask"
    condition:
        (uint32(0) == 0x464C457F) and filesize > 1MB and all of them 
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/crime_h2miner_kinsing.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/crime_nkminer.yar | rules: 1 =====
/*
   Yara Rule Set
   Author: Florian Roth
   Date: 2018-01-09
   Identifier: NK Miner Malware
   Reference: https://goo.gl/PChE1z
*/

/* Rule Set ----------------------------------------------------------------- */

rule NK_Miner_Malware_Jan18_1 {
   meta:
      description = "Detects Noth Korean Monero Miner mentioned in AlienVault report"
      author = "Florian Roth (Nextron Systems) (original rule by Chris Doman)"
      reference = "https://goo.gl/PChE1z"
      date = "2018-01-09"
      hash1 = "0024e32c0199ded445c0b968601f21cc92fc0c534d2642f2dd64c1c978ff01f3"
      hash2 = "42300b6a09f183ae167d7a11d9c6df21d022a5f02df346350d3d875d557d3b76"
      id = "40f53c36-9e14-5307-9740-e6f514afc7ec"
   strings:
      $x0 = "c:\\users\\jawhar\\documents\\" ascii
      $x1 = "C:\\Users\\Jawhar\\documents\\" ascii
      $x2 = "The number of processors on this computer is {0}." fullword wide
      $x3 = { 00 00 1F 43 00 3A 00 5C 00 4E 00 65 00 77 00 44
              00 69 00 72 00 65 00 63 00 74 00 6F 00 72 00 79
              00 00 }
      $x4 = "Le fichier Hello txt n'existe pas" fullword wide
      $x5 = "C:\\NewDirectory2\\info2" fullword wide

      /* Incorported from Chris Doman's rule - https://goo.gl/PChE1z*/
      $a = "82e999fb-a6e0-4094-aa1f-1a306069d1a5" ascii
      $b = "4JUdGzvrMFDWrUUwY3toJATSeNwjn54LkCnKBPRzDuhzi5vSepHfUckJNxRL2gjkNrSqtCoRUrEDAgRwsQvVCjZbRy5YeFCqgoUMnzumvS" ascii
      $c = "barjuok.ryongnamsan.edu.kp" wide ascii
      $d = "C:\\SoftwaresInstall\\soft" wide ascii
      $e = "C:\\Windows\\Sys64\\intelservice.exe" wide ascii
      $f = "C:\\Windows\\Sys64\\updater.exe" wide ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 30KB and 1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/crime_nkminer.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/crime_xbash.yar | rules: 3 =====
/*
   YARA Rule Set
   Author: Florian Roth
   Date: 2018-09-18
   Identifier: Xbash
   License: https://creativecommons.org/licenses/by-nc/4.0/
   Reference: https://researchcenter.paloaltonetworks.com/2018/09/unit42-xbash-combines-botnet-ransomware-coinmining-worm-targets-linux-windows/
*/

/* Rule Set ----------------------------------------------------------------- */

rule MAL_Xbash_PY_Sep18 {
   meta:
      description = "Detects Xbash malware"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://researchcenter.paloaltonetworks.com/2018/09/unit42-xbash-combines-botnet-ransomware-coinmining-worm-targets-linux-windows/"
      date = "2018-09-18"
      hash1 = "7a18c7bdf0c504832c8552766dcfe0ba33dd5493daa3d9dbe9c985c1ce36e5aa"
      id = "97512fe8-002f-5cbc-a915-d55c087fbef7"
   strings:
      $s1 = { 73 58 62 61 73 68 00 00 00 00 00 00 00 00 } /* sXbash\x00\x00\x00\x00\x00\x00 */
   condition:
      uint16(0) == 0x457f and filesize < 10000KB and 1 of them
}

rule MAL_Xbash_SH_Sep18 {
   meta:
      description = "Detects Xbash malware"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://researchcenter.paloaltonetworks.com/2018/09/unit42-xbash-combines-botnet-ransomware-coinmining-worm-targets-linux-windows/"
      date = "2018-09-18"
      modified = "2023-01-06"
      hash1 = "a27acc07844bb751ac33f5df569fd949d8b61dba26eb5447482d90243fc739af"
      hash2 = "de63ce4a42f06a5903b9daa62b67fcfbdeca05beb574f966370a6ae7fd21190d"
      id = "450ef15f-fe9c-5809-9077-457a43326bfe"
   strings:
      $s1 = "echo \"*/5 * * * * curl -fsSL" fullword ascii
      $s2 = ".sh|sh\" > /var/spool/cron/root" ascii
      $s3 = "#chmod +x /tmp/hawk" fullword ascii
      $s4 = "if [ ! -f \"/tmp/root.sh\" ]" fullword ascii
      $s5 = ".sh > /tmp/lower.sh" ascii
      $s6 = "chmod 777 /tmp/root.sh" fullword ascii
      $s7 = "-P /tmp && chmod +x /tmp/pools.txt" fullword ascii
      $s8 = "-C /tmp/pools.txt>/dev/null 2>&1" ascii
   condition:
      uint16(0) == 0x2123 and filesize < 3KB and 1 of them
}

rule MAL_Xbash_JS_Sep18 {
   meta:
      description = "Detects XBash malware"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://researchcenter.paloaltonetworks.com/2018/09/unit42-xbash-combines-botnet-ransomware-coinmining-worm-targets-linux-windows/"
      date = "2018-09-18"
      modified = "2023-01-06"
      hash1 = "f888dda9ca1876eba12ffb55a7a993bd1f5a622a30045a675da4955ede3e4cb8"
      id = "e891d146-f92d-5144-a1f2-ad308e309870"
   strings:
      $s1 = "var path=WSHShell" fullword ascii
      $s2 = "var myObject= new ActiveXObject(" ascii
      $s3 = "window.resizeTo(0,0)" fullword ascii
      $s4 = "<script language=\"JScript\">" fullword ascii /* Goodware String - occured 4 times */
   condition:
      filesize < 5KB and 3 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/crime_xbash.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/expl_libssh_cve_2023_2283_jun23.yar | rules: 1 =====
rule HKTL_EXPL_POC_LibSSH_Auth_Bypass_CVE_2023_2283_Jun23_1 {
   meta:
      description = "Detects POC code used in attacks against libssh vulnerability CVE-2023-2283"
      author = "Florian Roth"
      reference = "https://github.com/github/securitylab/tree/1786eaae7f90d87ce633c46bbaa0691d2f9bf449/SecurityExploits/libssh/pubkey-auth-bypass-CVE-2023-2283"
      date = "2023-06-08"
      score = 85
      id = "e72eba33-686f-5fca-bca3-2b875d1ec224"
   strings:
      $s1 = "nprocs = %d" ascii fullword
      $s2 = "fork failed: %s" ascii fullword
   condition:
      uint16(0) == 0x457f and all of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/expl_libssh_cve_2023_2283_jun23.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/expl_log4j_cve_2021_44228.yar | rules: 10 =====
rule EXPL_Log4j_CallBackDomain_IOCs_Dec21_1 {
   meta:
      description = "Detects IOCs found in Log4Shell incidents that indicate exploitation attempts of CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://gist.github.com/superducktoes/9b742f7b44c71b4a0d19790228ce85d8"
      date = "2021-12-12"
      score = 60
      id = "474afa96-1758-587e-8cab-41c5205e245e"
   strings:
      $xr1  = /\b(ldap|rmi):\/\/([a-z0-9\.]{1,16}\.bingsearchlib\.com|[a-z0-9\.]{1,40}\.interact\.sh|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}):[0-9]{2,5}\/([aZ]|ua|Exploit|callback|[0-9]{10}|http443useragent|http80useragent)\b/
   condition:
      1 of them
}

rule EXPL_JNDI_Exploit_Patterns_Dec21_1 {
   meta:
      description = "Detects JNDI Exploit Kit patterns in files"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://github.com/pimps/JNDI-Exploit-Kit"
      date = "2021-12-12"
      score = 60
      id = "a9127dd2-b818-5ca8-877a-3c47b1e92606"
   strings:
      $x01 = "/Basic/Command/Base64/"
      $x02 = "/Basic/ReverseShell/"
      $x03 = "/Basic/TomcatMemshell"
      $x04 = "/Basic/JettyMemshell"
      $x05 = "/Basic/WeblogicMemshell"
      $x06 = "/Basic/JBossMemshell"
      $x07 = "/Basic/WebsphereMemshell"
      $x08 = "/Basic/SpringMemshell"
      $x09 = "/Deserialization/URLDNS/"
      $x10 = "/Deserialization/CommonsCollections1/Dnslog/"
      $x11 = "/Deserialization/CommonsCollections2/Command/Base64/"
      $x12 = "/Deserialization/CommonsBeanutils1/ReverseShell/"
      $x13 = "/Deserialization/Jre8u20/TomcatMemshell"
      $x14 = "/TomcatBypass/Dnslog/"
      $x15 = "/TomcatBypass/Command/"
      $x16 = "/TomcatBypass/ReverseShell/"
      $x17 = "/TomcatBypass/TomcatMemshell"
      $x18 = "/TomcatBypass/SpringMemshell"
      $x19 = "/GroovyBypass/Command/"
      $x20 = "/WebsphereBypass/Upload/"

      $fp1 = "<html"
   condition:
      1 of ($x*) and not 1 of ($fp*)
}

rule EXPL_Log4j_CVE_2021_44228_JAVA_Exception_Dec21_1 {
   meta:
      description = "Detects exceptions found in server logs that indicate an exploitation attempt of CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://gist.github.com/Neo23x0/e4c8b03ff8cdf1fa63b7d15db6e3860b"
      date = "2021-12-12"
      score = 60
      id = "82cf337e-4ea1-559b-a7b8-512a07adf06f"
   strings:
      $xa1 = "header with value of BadAttributeValueException: "
      
      $sa1 = ".log4j.core.net.JndiManager.lookup(JndiManager"
      $sa2 = "Error looking up JNDI resource"
   condition:
      $xa1 or all of ($sa*)
}

rule EXPL_Log4j_CVE_2021_44228_Dec21_Soft : FILE {
   meta:
      description = "Detects indicators in server logs that indicate an exploitation attempt of CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/h113sdx/status/1469010902183661568?s=20"
      date = "2021-12-10"
      modified = "2025-03-24"
      score = 50
      id = "87e536a5-cc11-528a-b100-4fa3b2b7bc0c"
   strings:
      $x01 = "${jndi:ldap:/"
      $x02 = "${jndi:rmi:/"
      $x03 = "${jndi:ldaps:/"
      $x04 = "${jndi:dns:/"
      $x05 = "${jndi:iiop:/"
      $x06 = "${jndi:http:/"
      $x07 = "${jndi:nis:/"
      $x08 = "${jndi:nds:/"
      $x09 = "${jndi:corba:/"

      $fp1 = "<html"
      $fp2 = "/nessus}"
   condition:
      1 of ($x*) and not 1 of ($fp*)
}

rule EXPL_Log4j_CVE_2021_44228_Dec21_OBFUSC {
   meta:
      description = "Detects obfuscated indicators in server logs that indicate an exploitation attempt of CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/h113sdx/status/1469010902183661568?s=20"
      date = "2021-12-12"
      modified = "2021-12-13"
      score = 60
      id = "d7c4092a-6ffc-5a89-b73a-f7f0ac984cbd"
   strings:
      $x1 = "$%7Bjndi:"
      $x2 = "%2524%257Bjndi"
      $x3 = "%2F%252524%25257Bjndi%3A"
      $x4 = "${jndi:${lower:"
      $x5 = "${::-j}${"
      $x6 = "${${env:BARFOO:-j}"
      $x7 = "${::-l}${::-d}${::-a}${::-p}"
      $x8 = "${base64:JHtqbmRp"

      $fp1 = "<html"
   condition:
      1 of ($x*) and not 1 of ($fp*)
}

rule EXPL_Log4j_CVE_2021_44228_Dec21_Hard : FILE {
   meta:
      description = "Detects indicators in server logs that indicate the exploitation of CVE-2021-44228"
      author = "Florian Roth"
      reference = "https://twitter.com/h113sdx/status/1469010902183661568?s=20"
      date = "2021-12-10"
      modified = "2025-03-20"
      score = 65
      id = "5297c42d-7138-507d-a3eb-153afe522816"
   strings:
      $x1 = /\$\{jndi:(ldap|ldaps|rmi|dns|iiop|http|nis|nds|corba):\/[\/]?[a-z-\.0-9]{3,120}:[0-9]{2,5}\/[a-zA-Z\.]{1,32}\}/
      $x2 = "Reference Class Name: foo"
      $fp1r = /(ldap|rmi|ldaps|dns):\/[\/]?(127\.0\.0\.1|192\.168\.|172\.[1-3][0-9]\.|10\.)/

      $fpg2 = "<html"
      $fpg3 = "<HTML"
      
      $fp1 = "/QUALYSTEST" ascii
      $fp2 = "w.nessus.org/nessus"
      $fp3 = "/nessus}"
   condition:
      1 of ($x*) and not 1 of ($fp*)
}

rule SUSP_Base64_Encoded_Exploit_Indicators_Dec21 {
   meta:
      description = "Detects base64 encoded strings found in payloads of exploits against log4j CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/Reelix/status/1469327487243071493"
      date = "2021-12-10"
      modified = "2021-12-13"
      score = 70
      id = "09abc4f0-ace7-5f53-b1d3-5f5c6bf3bdba"
   strings:
      /* curl -s  */
      $sa1 = "Y3VybCAtcy"
      $sa2 = "N1cmwgLXMg"
      $sa3 = "jdXJsIC1zI"
      /* |wget -q -O-  */
      $sb1 = "fHdnZXQgLXEgLU8tI"
      $sb2 = "x3Z2V0IC1xIC1PLS"
      $sb3 = "8d2dldCAtcSAtTy0g"

      $fp1 = "<html"
   condition:
      1 of ($sa*) and 1 of ($sb*)
      and not 1 of ($fp*)
}

rule SUSP_JDNIExploit_Indicators_Dec21 {
   meta:
      description = "Detects indicators of JDNI usage in log files and other payloads"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://github.com/flypig5211/JNDIExploit"
      date = "2021-12-10"
      modified = "2021-12-12"
      score = 70
      id = "2df8b8f3-8d8d-5982-8c85-692b7d91ebb2"
   strings:
      $xr1 = /(ldap|ldaps|rmi|dns|iiop|http|nis|nds|corba):\/\/[a-zA-Z0-9\.]{7,80}:[0-9]{2,5}\/(Basic\/Command\/Base64|Basic\/ReverseShell|Basic\/TomcatMemshell|Basic\/JBossMemshell|Basic\/WebsphereMemshell|Basic\/SpringMemshell|Basic\/Command|Deserialization\/CommonsCollectionsK|Deserialization\/CommonsBeanutils|Deserialization\/Jre8u20\/TomcatMemshell|Deserialization\/CVE_2020_2555\/WeblogicMemshell|TomcatBypass|GroovyBypass|WebsphereBypass)\//
   condition:
      filesize < 100MB and $xr1
}

rule SUSP_EXPL_OBFUSC_Dec21_1{
   meta:
      description = "Detects obfuscation methods used to evade detection in log4j exploitation attempt of CVE-2021-44228"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/testanull/status/1469549425521348609"
      date = "2021-12-11"
      modified = "2022-11-08"
      score = 60
      id = "b8f56711-7922-54b9-9ce2-6ba05d64c80d"
   strings:
      /* ${lower:X} - single character match */
      $f1 = { 24 7B 6C 6F 77 65 72 3A ?? 7D }
      /* ${upper:X} - single character match */
      $f2 = { 24 7B 75 70 70 65 72 3A ?? 7D }
      /* URL encoded lower - obfuscation in URL */
      $x3 = "$%7blower:"
      $x4 = "$%7bupper:"
      $x5 = "%24%7bjndi:"
      $x6 = "$%7Blower:"
      $x7 = "$%7Bupper:"
      $x8 = "%24%7Bjndi:"

      $fp1 = "<html"
   condition:
      ( 
         1 of ($x*) or 
         filesize < 200KB and 1 of ($f*) 
      ) 
      and not 1 of ($fp*)
}

rule SUSP_JDNIExploit_Error_Indicators_Dec21_1 {
   meta:
      description = "Detects error messages related to JDNI usage in log files that can indicate a Log4Shell / Log4j exploitation"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/marcioalm/status/1470361495405875200?s=20"
      date = "2021-12-10"
      modified = "2023-06-23"
      score = 70
      id = "68bcf043-58b4-54a9-b024-64871b5d535f"
   strings:
      $x1 = "FATAL log4j - Message: BadAttributeValueException: "
   condition:
      1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/expl_log4j_cve_2021_44228.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/expl_spring4shell.yar | rules: 3 =====
/* Old webshell rule from THOR's signature set - donation to the community */ 
rule WEBSHELL_JSP_Nov21_1 {
   meta:
      description = "Detects JSP webshells"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://www.ic3.gov/Media/News/2021/211117-2.pdf"
      date = "2021-11-23"
      score = 70
      id = "117eed28-c44e-5983-b4c7-b555fc06d923"
   strings:
      $x1 = "request.getParameter(\"pwd\")" ascii
      $x2 = "excuteCmd(request.getParameter(" ascii
      $x3 = "getRuntime().exec (request.getParameter(" ascii
      $x4 = "private static final String PW = \"whoami\"" ascii
   condition:
      filesize < 400KB and 1 of them
}

rule EXPL_POC_SpringCore_0day_Indicators_Mar22_1 {
   meta:
      description = "Detects indicators found after SpringCore exploitation attempts and in the POC script"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/vxunderground/status/1509170582469943303"
      date = "2022-03-30"
      score = 70
      id = "297e4b57-f831-56e0-a391-1ffbc9a4d438"
   strings:
      $x1 = "java.io.InputStream%20in%20%3D%20%25%7Bc1%7Di"
      $x2 = "?pwd=j&cmd=whoami"
      $x3 = ".getParameter(%22pwd%22)"
      $x4 = "class.module.classLoader.resources.context.parent.pipeline.first.pattern=%25%7B"
   condition:
      1 of them
}

rule EXPL_POC_SpringCore_0day_Webshell_Mar22_1 {
   meta:
      description = "Detects webshell found after SpringCore exploitation attempts POC script"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://twitter.com/vxunderground/status/1509170582469943303"
      date = "2022-03-30"
      score = 70
      id = "e7047c98-3c60-5211-9ad5-2bfdfb35d493"
   strings:
      $x1 = ".getInputStream(); int a = -1; byte[] b = new byte[2048];"
      $x2 = "if(\"j\".equals(request.getParameter(\"pwd\")"
      $x3 = ".getRuntime().exec(request.getParameter(\"cmd\")).getInputStream();"
   condition:
     filesize < 200KB and 1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/expl_spring4shell.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/gen_elf_file_anomalies.yar | rules: 1 =====
rule SUSP_ELF_LNX_UPX_Compressed_File {
   meta:
      description = "Detects a suspicious ELF binary with UPX compression"
      author = "Florian Roth (Nextron Systems)"
      reference = "Internal Research"
      date = "2018-12-12"
      score = 40
      hash1 = "038ff8b2fef16f8ee9d70e6c219c5f380afe1a21761791e8cbda21fa4d09fdb4"
      id = "078937de-59b3-538e-a5c3-57f4e6050212"
   strings:
      $s1 = "PROT_EXEC|PROT_WRITE failed." fullword ascii
      $s2 = "$Id: UPX" fullword ascii
      $s3 = "$Info: This file is packed with the UPX executable packer" ascii

      $fp1 = "check your UCL installation !"
   condition:
      uint16(0) == 0x457f and filesize < 2000KB and
      filesize > 30KB and 2 of ($s*)
      and not 1 of ($fp*)
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/gen_elf_file_anomalies.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/gen_python_pty_shell.yar | rules: 1 =====
rule HKTL_Reverse_Connect_TCP_PTY_Shell {
   meta:
      description = "Detects reverse connect TCP PTY shell"
      author = "Jeff Beley"
      date = "2019-10-19"
      hash1 = "cae9833292d3013774bdc689d4471fd38e4a80d2d407adf9fa99bc8cde3319bf"
      reference = "https://github.com/infodox/python-pty-shells/blob/master/tcp_pty_backconnect.py"
      id = "a9a90d67-774b-5b32-97c0-d7e06763f2e9"
   strings:
      $s1 = "os.dup2(s.fileno(),1)" fullword ascii
      $s2 = "pty.spawn(\"/bin/\")" fullword ascii
      $s3 = "os.putenv(\"HISTFILE\",'/dev/null')" fullword ascii
      $s4 = "socket.socket(socket.AF_INET, socket.SOCK_STREAM)" fullword ascii
   condition:
      filesize < 1KB and 2 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/gen_python_pty_shell.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/gen_python_reverse_shell.yara | rules: 1 =====
rule gen_python_reverse_shell
{
   meta:
      description = "Python Base64 encoded reverse shell"
      author = "John Lambert @JohnLaTwC"
      reference = "https://www.virustotal.com/en/file/9ec5102bcbabc45f2aa7775464f33019cfbe9d766b1332ee675957c923a17efd/analysis/"
      date = "2018-02-24"
      hash1 = "9ec5102bcbabc45f2aa7775464f33019cfbe9d766b1332ee675957c923a17efd"
      hash2 = "bfb5c622a3352bb71b86df81c45ccefaa68b9f7cc0a3577e8013aad951308f12"
      id = "dda831ae-d0ca-5d5a-bdb3-e7c146a770b4"
   strings:
      $h1 = "import base64" fullword ascii

      $s1 = "b64decode" fullword ascii
      $s2 = "lambda" fullword ascii
      $s3 = "version_info" fullword ascii

      //Base64 encoded versions of these strings
      // socket.SOCK_STREAM
      $enc_x0 = /(AG8AYwBrAGUAdAAuAFMATwBDAEsAXwBTAFQAUgBFAEEATQ|b2NrZXQuU09DS19TVFJFQU|c29ja2V0LlNPQ0tfU1RSRUFN|cwBvAGMAawBlAHQALgBTAE8AQwBLAF8AUwBUAFIARQBBAE0A|MAbwBjAGsAZQB0AC4AUwBPAEMASwBfAFMAVABSAEUAQQBNA|NvY2tldC5TT0NLX1NUUkVBT)/ ascii

      //.connect((
      $enc_x1 = /(4AYwBvAG4AbgBlAGMAdAAoACgA|5jb25uZWN0KC|AGMAbwBuAG4AZQBjAHQAKAAoA|LgBjAG8AbgBuAGUAYwB0ACgAKA|LmNvbm5lY3QoK|Y29ubmVjdCgo)/

      //time.sleep
      $enc_x2 = /(AGkAbQBlAC4AcwBsAGUAZQBwA|aW1lLnNsZWVw|dABpAG0AZQAuAHMAbABlAGUAcA|dGltZS5zbGVlc|QAaQBtAGUALgBzAGwAZQBlAHAA|RpbWUuc2xlZX)/

      //.recv
      $enc_x3 = /(4AcgBlAGMAdg|5yZWN2|AHIAZQBjAHYA|cmVjd|LgByAGUAYwB2A|LnJlY3)/
   condition:
      uint32be(0) == 0x696d706f
      and $h1 at 0
      and filesize < 40KB
      and all of ($s*)
      and all of ($enc_x*)
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/gen_python_reverse_shell.yara =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/mal_lnx_implant_may22.yar | rules: 6 =====
rule MAL_LNX_RedMenshen_BPFDoor_May23_1 {
   meta:
      description = "Detects BPFDoor malware"
      author = "Florian Roth"
      reference = "https://www.deepinstinct.com/blog/bpfdoor-malware-evolves-stealthy-sniffing-backdoor-ups-its-game"
      date = "2023-05-11"
      score = 80
      hash1 = "afa8a32ec29a31f152ba20a30eb483520fe50f2dce6c9aa9135d88f7c9c511d7"
      id = "25df4dba-ec6e-5999-b6be-56fe933cb0d0"
   strings:
      $x1 = "[-] Execute command failed" ascii fullword
      $x2 = "/var/run/initd.lock" ascii fullword
      
      $xc1 = { 2F 00 3E 3E 00 65 78 69 74 00 72 00 }

      $sc1 = { 9F CD 30 44 }
      $sc2 = { 66 27 14 5E }

      $sa1 = "TLS-CHACHA20-POLY1305-SHA256" ascii fullword

      $sop1 = { 48 83 c0 01 4c 39 f8 75 ea 4c 89 7c 24 68 48 69 c3 d0 00 00 00 48 8b 5c 24 50 48 8b 54 24 78 48 c7 44 24 38 00 00 00 00 }
      $sop2 = { 48 89 de f3 a5 89 03 8b 44 24 2c 39 44 24 28 44 89 4b 04 48 89 53 10 0f 95 c0 }
      $sop3 = { 49 d3 cd 4d 31 cd b1 29 49 89 e9 49 d3 c8 4d 31 c5 4c 03 68 10 48 89 f9 }
   condition:
      // file-based detection
      uint16(0) == 0x457f and
      filesize < 900KB and (
         ( 1 of ($x*) and 1 of ($s*) )
         or 4 of them
         /* looks for the magic byte sequences in close proximity to each other */
         or ( 
            all of ($sc*) 
            and $sc1 in (@sc2[1]-50..@sc2[1]+50) 
         )
      // in-memory detection
      ) or (
         2 of ($x*)
         or 5 of them
      )
}


rule APT_MAL_LNX_RedMenshen_BPFDoor_Controller_May22_1 {
   meta:
      description = "Detects unknown Linux implants (uploads from KR and MO)"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://doublepulsar.com/bpfdoor-an-active-chinese-global-surveillance-tool-54b078f1a896"
      date = "2022-05-05"
      score = 90
      hash1 = "07ecb1f2d9ffbd20a46cd36cd06b022db3cc8e45b1ecab62cd11f9ca7a26ab6d"
      hash2 = "4c5cf8f977fc7c368a8e095700a44be36c8332462c0b1e41bff03238b2bf2a2d"
      hash3 = "599ae527f10ddb4625687748b7d3734ee51673b664f2e5d0346e64f85e185683"
      hash4 = "5b2a079690efb5f4e0944353dd883303ffd6bab4aad1f0c88b49a76ddcb28ee9"
      hash5 = "5faab159397964e630c4156f8852bcc6ee46df1cdd8be2a8d3f3d8e5980f3bb3"
      hash6 = "93f4262fce8c6b4f8e239c35a0679fbbbb722141b95a5f2af53a2bcafe4edd1c"
      hash7 = "97a546c7d08ad34dfab74c9c8a96986c54768c592a8dae521ddcf612a84fb8cc"
      hash8 = "c796fc66b655f6107eacbe78a37f0e8a2926f01fecebd9e68a66f0e261f91276"
      hash9 = "f8a5e735d6e79eb587954a371515a82a15883cf2eda9d7ddb8938b86e714ea27"
      hash10 = "fd1b20ee5bd429046d3c04e9c675c41e9095bea70e0329bd32d7edd17ebaf68a"
      id = "1438c3bf-3c42-59d5-9f3f-2d72bdaaac42"
   strings:
      $s1 = "[-] Connect failed." ascii fullword
      $s2 = "export MYSQL_HISTFILE=" ascii fullword
      $s3 = "udpcmd" ascii fullword
      $s4 = "getshell" ascii fullword

      $op1 = { e8 ?? ff ff ff 80 45 ee 01 0f b6 45 ee 3b 45 d4 7c 04 c6 45 ee 00 80 45 ff 01 80 7d ff 00 }
      $op2 = { 55 48 89 e5 48 83 ec 30 89 7d ec 48 89 75 e0 89 55 dc 83 7d dc 00 75 0? }
      $op3 = { e8 a? fe ff ff 0f b6 45 f6 48 03 45 e8 0f b6 10 0f b6 45 f7 48 03 45 e8 0f b6 00 8d 04 02 }
      $op4 = { c6 80 01 01 00 00 00 48 8b 45 c8 0f b6 90 01 01 00 00 48 8b 45 c8 88 90 00 01 00 00 c6 45 ef 00 0f b6 45 ef 88 45 ee }
   condition:
      uint16(0) == 0x457f and
      filesize < 80KB and 2 of them or 5 of them
}

rule APT_MAL_LNX_RedMenshen_BPFDoor_Controller_May22_2 {
   meta:
      description = "Detects BPFDoor implants used by Chinese actor Red Menshen"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://doublepulsar.com/bpfdoor-an-active-chinese-global-surveillance-tool-54b078f1a896"
      date = "2022-05-07"
      score = 85
      hash1 = "76bf736b25d5c9aaf6a84edd4e615796fffc338a893b49c120c0b4941ce37925"
      hash2 = "96e906128095dead57fdc9ce8688bb889166b67c9a1b8fdb93d7cff7f3836bb9"
      hash3 = "c80bd1c4a796b4d3944a097e96f384c85687daeedcdcf05cc885c8c9b279b09c"
      hash4 = "f47de978da1dbfc5e0f195745e3368d3ceef034e964817c66ba01396a1953d72"
      id = "d5c3d530-ed6f-563e-a3b0-55d4c82e4899"
   strings:
      $opx1 = { 48 83 c0 0c 48 8b 95 e8 fe ff ff 48 83 c2 0c 8b 0a 8b 55 f0 01 ca 89 10 c9 }
      $opx2 = { 48 01 45 e0 83 45 f4 01 8b 45 f4 3b 45 dc 7c cd c7 45 f4 00 00 00 00 eb 2? 48 8b 05 ?? ?? 20 00 }

      $op1 = { 48 8d 14 c5 00 00 00 00 48 8b 45 d0 48 01 d0 48 8b 00 48 89 c7 e8 ?? ?? ff ff 48 83 c0 01 48 01 45 e0 }
      $op2 = { 89 c2 8b 85 fc fe ff ff 01 c2 8b 45 f4 01 d0 2d 7b cf 10 2b 89 45 f4 c1 4d f4 10 }
      $op3 = { e8 ?? d? ff ff 8b 45 f0 eb 12 8b 85 3c ff ff ff 89 c7 e8 ?? d? ff ff b8 ff ff ff ff c9 }
   condition:
      uint16(0) == 0x457f and
      filesize < 100KB and 2 of ($opx*) or 4 of them
}

rule APT_MAL_LNX_RedMenshen_BPFDoor_Controller_May22_3 {
   meta:
      description = "Detects BPFDoor implants used by Chinese actor Red Menshen"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://doublepulsar.com/bpfdoor-an-active-chinese-global-surveillance-tool-54b078f1a896"
      date = "2022-05-08"
      score = 85
      hash1 = "144526d30ae747982079d5d340d1ff116a7963aba2e3ed589e7ebc297ba0c1b3"
      hash2 = "fa0defdabd9fd43fe2ef1ec33574ea1af1290bd3d763fdb2bed443f2bd996d73"
      id = "91c2153a-a6e0-529e-852c-61f799838798"
   strings:
      $s1 = "hald-addon-acpi: listening on acpi kernel interface /proc/acpi/event" ascii fullword
      $s2 = "/sbin/mingetty /dev" ascii fullword
      $s3 = "pickup -l -t fifo -u" ascii fullword
   condition:
      uint16(0) == 0x457f and
      filesize < 200KB and 2 of them or all of them
}

rule APT_MAL_LNX_RedMenshen_BPFDoor_Controller_Generic_May22_1 {
   meta:
      description = "Detects BPFDoor malware"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://doublepulsar.com/bpfdoor-an-active-chinese-global-surveillance-tool-54b078f1a896"
      date = "2022-05-09"
      score = 90
      hash1 = "07ecb1f2d9ffbd20a46cd36cd06b022db3cc8e45b1ecab62cd11f9ca7a26ab6d"
      hash2 = "1925e3cd8a1b0bba0d297830636cdb9ebf002698c8fa71e0063581204f4e8345"
      hash3 = "4c5cf8f977fc7c368a8e095700a44be36c8332462c0b1e41bff03238b2bf2a2d"
      hash4 = "591198c234416c6ccbcea6967963ca2ca0f17050be7eed1602198308d9127c78"
      hash5 = "599ae527f10ddb4625687748b7d3734ee51673b664f2e5d0346e64f85e185683"
      hash6 = "5b2a079690efb5f4e0944353dd883303ffd6bab4aad1f0c88b49a76ddcb28ee9"
      hash7 = "5faab159397964e630c4156f8852bcc6ee46df1cdd8be2a8d3f3d8e5980f3bb3"
      hash8 = "76bf736b25d5c9aaf6a84edd4e615796fffc338a893b49c120c0b4941ce37925"
      hash9 = "93f4262fce8c6b4f8e239c35a0679fbbbb722141b95a5f2af53a2bcafe4edd1c"
      hash10 = "96e906128095dead57fdc9ce8688bb889166b67c9a1b8fdb93d7cff7f3836bb9"
      hash11 = "97a546c7d08ad34dfab74c9c8a96986c54768c592a8dae521ddcf612a84fb8cc"
      hash12 = "c796fc66b655f6107eacbe78a37f0e8a2926f01fecebd9e68a66f0e261f91276"
      hash13 = "c80bd1c4a796b4d3944a097e96f384c85687daeedcdcf05cc885c8c9b279b09c"
      hash14 = "f47de978da1dbfc5e0f195745e3368d3ceef034e964817c66ba01396a1953d72"
      hash15 = "f8a5e735d6e79eb587954a371515a82a15883cf2eda9d7ddb8938b86e714ea27"
      hash16 = "fa0defdabd9fd43fe2ef1ec33574ea1af1290bd3d763fdb2bed443f2bd996d73"
      hash17 = "fd1b20ee5bd429046d3c04e9c675c41e9095bea70e0329bd32d7edd17ebaf68a"
      id = "d30df2ae-7008-53c0-9a61-8346a9c9f465"
   strings:
      $op1 = { c6 80 01 01 00 00 00 48 8b 45 ?8 0f b6 90 01 01 00 00 48 8b 45 ?8 88 90 00 01 00 00 c6 45 ?? 00 0f b6 45 ?? 88 45 }
      $op2 = { 48 89 55 c8 48 8b 45 c8 48 89 45 ?? 48 8b 45 c8 0f b6 80 00 01 00 00 88 45 f? 48 8b 45 c8 0f b6 80 01 01 00 00 }
      $op3 = { 48 89 45 ?? 48 8b 45 c8 0f b6 80 00 01 00 00 88 45 f? 48 8b 45 c8 0f b6 80 01 01 00 00 88 45 f? c7 45 f8 00 00 00 00 }
      $op4 = { 48 89 7d d8 89 75 d4 48 89 55 c8 48 8b 45 c8 48 89 45 ?? 48 8b 45 c8 0f b6 80 00 01 00 00 88 45 f? }
      $op5 = { 48 8b 45 ?8 c6 80 01 01 00 00 00 48 8b 45 ?8 0f b6 90 01 01 00 00 48 8b 45 ?8 88 90 00 01 00 00 c6 45 ?? 00 0f b6 45 }
      $op6 = { 89 75 d4 48 89 55 c8 48 8b 45 c8 48 89 45 ?? 48 8b 45 c8 0f b6 80 00 01 00 00 88 45 f? 48 8b 45 c8 }
   condition:
      uint16(0) == 0x457f and
      filesize < 200KB and 2 of them or 4 of them
}

/* prone to FPs https://github.com/Neo23x0/signature-base/issues/282
rule APT_MAL_LNX_RedMenshen_BPFDoor_Tricephalic_Implant_May22 {

    meta:
      description = "Detects BPFDoor/Tricephalic Hellkeeper passive implant"
      author = "Exatrack"
      reference = "https://exatrack.com/public/Tricephalic_Hellkeeper.pdf"
      date = "2022-05-09"
      score = 90

    strings:
        $str_message_01 = "hald-addon-acpi: listening on acpi kernel interface /proc/acpi/event"
        $str_message__02 = "/var/run/haldrund.pid"
        
        //$str_message_03 = "/bin/rm -f /dev/shm/%s;/bin/cp %s /dev/shm/%s && /bin/chmod 755 /dev/shm/%s && /dev/shm/%s --init && /bin/rm -f /dev/shm/%s" // in the stack
        
        $str_message_04 = "Cant fork pty"
        $str_hald_05 = "/sbin/iptables -t nat -D PREROUTING -p tcp -s %s --dport %d -j REDIRECT --to-ports %d"
        
        //$str_command_01 = "/sbin/iptables -t nat -A PREROUTING -p tcp -s %s --dport %d -j REDIRECT --to-ports %d"
        //$str_command_02 = "/sbin/iptables -I INPUT -p tcp -s %s -j ACCEPT"
        
        $str_command_03 = "/bin/rm -f /dev/shm/%s"
        
        //$str_command_04 = "/bin/cp %s /dev/shm/%s"
        //$str_command_05 = "/bin/chmod 755 /dev/shm/%s"

        // $str_command_06 = "/dev/shm/%s --init"
        // $str_server_01 = "[+] Spawn shell ok."
        // $str_server_02 = "[+] Monitor packet send."

        $str_server_03 = "[-] Spawn shell failed."
        $str_server_04 = "[-] Can't write auth challenge"
        $str_server_05 = "[+] Packet Successfuly Sending %d Size."
        $str_server_06 = "[+] Challenging %s."
        $str_server_07 = "[+] Auth send ok."
        $str_server_08 = "[+] possible windows"

        $str_filter_01 = "(udp[8:2]=0x7255)"
        $str_filter_02 = "(icmp[8:2]=0x7255)"
        $str_filter_03 = "(tcp[((tcp[12]&0xf0)>>2):2]=0x5293)"
        
        // $str_filter_04 = {15 00 ?? ?? 55 72 00 00}
        //$str_filter_05 = {15 00 ?? ?? 93 52 00 00}
        
        $error_01 = "[-] socket"
        $error_02 = "[-] listen"
        $error_03 = "[-] bind"
        $error_04 = "[-] accept"
        $error_05 = "[-] Mode error."
        $error_06 = "[-] bind port failed."
        $error_07 = "[-] setsockopt"
        $error_08 = "[-] missing -s"
        $error_09 = "[-] sendto"
    condition:
        any of ($str*) or 3 of ($error*)
}
*/
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/mal_lnx_implant_may22.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/pua_cryptocoin_miner.yar | rules: 4 =====
rule CoinMiner_Strings : SCRIPT HIGHVOL {
   meta:
      description = "Detects mining pool protocol string in Executable"
      author = "Florian Roth (Nextron Systems)"
      score = 60
      reference = "https://minergate.com/faq/what-pool-address"
      date = "2018-01-04"
      modified = "2021-10-26"
      nodeepdive = 1
      id = "ac045f83-5f32-57a9-8011-99a2658a0e05"
   strings:
      $sa1 = "stratum+tcp://" ascii
      $sa2 = "stratum+udp://" ascii
      $sb1 = "\"normalHashing\": true,"
   condition:
      filesize < 3000KB and 1 of them
}

rule CoinHive_Javascript_MoneroMiner : HIGHVOL {
   meta:
      description = "Detects CoinHive - JavaScript Crypto Miner"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      score = 50
      reference = "https://coinhive.com/documentation/miner"
      date = "2018-01-04"
      id = "4f40c342-fcdc-5c73-a3cf-7b2ed438eaaf"
   strings:
      $s2 = "CoinHive.CONFIG.REQUIRES_AUTH" fullword ascii
   condition:
      filesize < 65KB and 1 of them
}

rule PUA_CryptoMiner_Jan19_1 {
   meta:
      description = "Detects Crypto Miner strings"
      author = "Florian Roth (Nextron Systems)"
      reference = "Internal Research"
      date = "2019-01-31"
      score = 80
      hash1 = "ede858683267c61e710e367993f5e589fcb4b4b57b09d023a67ea63084c54a05"
      id = "aebfdce9-c2dd-5f24-aa25-071e1a961239"
   strings:
      $s1 = "Stratum notify: invalid Merkle branch" fullword ascii
      $s2 = "-t, --threads=N       number of miner threads (default: number of processors)" fullword ascii
      $s3 = "User-Agent: cpuminer/" ascii
      $s4 = "hash > target (false positive)" fullword ascii
      $s5 = "thread %d: %lu hashes, %s khash/s" fullword ascii
   condition:
      filesize < 1000KB and 1 of them
}

rule PUA_Crypto_Mining_CommandLine_Indicators_Oct21 : SCRIPT {
   meta:
      description = "Detects command line parameters often used by crypto mining software"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://www.poolwatch.io/coin/monero"
      date = "2021-10-24"
      score = 65
      id = "afe5a63a-08c3-5cb7-b4b1-b996068124b7"
   strings:
      $s01 = " --cpu-priority="
      $s02 = "--donate-level=0"
      $s03 = " -o pool."
      $s04 = " -o stratum+tcp://"
      $s05 = " --nicehash"
      $s06 = " --algo=rx/0 "

      /* base64 encoded: --donate-level= */
      $se1 = "LS1kb25hdGUtbGV2ZWw9"
      $se2 = "0tZG9uYXRlLWxldmVsP"
      $se3 = "tLWRvbmF0ZS1sZXZlbD"

      /* 
         base64 encoded:
         stratum+tcp:// 
         stratum+udp:// 
      */
      $se4 = "c3RyYXR1bSt0Y3A6Ly"
      $se5 = "N0cmF0dW0rdGNwOi8v"
      $se6 = "zdHJhdHVtK3RjcDovL"
      $se7 = "c3RyYXR1bSt1ZHA6Ly"
      $se8 = "N0cmF0dW0rdWRwOi8v"
      $se9 = "zdHJhdHVtK3VkcDovL"
   condition:
      filesize < 5000KB and 1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/pua_cryptocoin_miner.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/pua_xmrig_monero_miner.yar | rules: 4 =====
/*
   Yara Rule Set
   Author: Florian Roth
   Date: 2018-01-04
   Identifier: XMRIG
   Reference: https://github.com/xmrig/xmrig/releases
*/

/* Rule Set ----------------------------------------------------------------- */

rule XMRIG_Monero_Miner : HIGHVOL {
   meta:
      description = "Detects Monero mining software"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://github.com/xmrig/xmrig/releases"
      date = "2018-01-04"
      modified = "2022-11-10"
      modified = "2022-11-10"
      hash1 = "5c13a274adb9590249546495446bb6be5f2a08f9dcd2fc8a2049d9dc471135c0"
      hash2 = "08b55f9b7dafc53dfc43f7f70cdd7048d231767745b76dc4474370fb323d7ae7"
      hash3 = "f3f2703a7959183b010d808521b531559650f6f347a5830e47f8e3831b10bad5"
      hash4 = "0972ea3a41655968f063c91a6dbd31788b20e64ff272b27961d12c681e40b2d2"
      id = "71bf1b9c-c806-5737-83a9-d6013872b11d"
   strings:
      $s1 = "'h' hashrate, 'p' pause, 'r' resume" fullword ascii
      $s2 = "--cpu-affinity" ascii
      $s3 = "set process affinity to CPU core(s), mask 0x3 for cores 0 and 1" ascii
      $s4 = "password for mining server" fullword ascii
      $s5 = "XMRig/%s libuv/%s%s" fullword ascii
   condition:
      ( uint16(0) == 0x5a4d or uint16(0) == 0x457f ) and filesize < 10MB and 2 of them
}

rule XMRIG_Monero_Miner_Config {
   meta:
      description = "Auto-generated rule - from files config.json, config.json"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://github.com/xmrig/xmrig/releases"
      date = "2018-01-04"
      hash1 = "031333d44a3a917f9654d7e7257e00c9d961ada3bee707de94b7c7d06234909a"
      hash2 = "409b6ec82c3bdac724dae702e20cb7f80ca1e79efa4ff91212960525af016c41"
      id = "374efe7f-9ef2-5974-8e24-f749183ab2d0"
   strings:
      $s2 = "\"cpu-affinity\": null,   // set process affinity to CPU core(s), mask \"0x3\" for cores 0 and 1" fullword ascii
      $s5 = "\"nicehash\": false                  // enable nicehash/xmrig-proxy support" fullword ascii
      $s8 = "\"algo\": \"cryptonight\",  // cryptonight (default) or cryptonight-lite" fullword ascii
   condition:
      ( uint16(0) == 0x0a7b or uint16(0) == 0x0d7b ) and filesize < 5KB and 1 of them
}

rule PUA_LNX_XMRIG_CryptoMiner {
   meta:
      description = "Detects XMRIG CryptoMiner software"
      license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
      author = "Florian Roth (Nextron Systems)"
      reference = "Internal Research"
      date = "2018-06-28"
      modified = "2023-01-06"
      hash1 = "10a72f9882fc0ca141e39277222a8d33aab7f7a4b524c109506a407cd10d738c"
      id = "bbdeff2e-68cc-5bbe-b843-3cba9c8c7ea8"
   strings:
      $x1 = "number of hash blocks to process at a time (don't set or 0 enables automatic selection o" fullword ascii
      $s2 = "'h' hashrate, 'p' pause, 'r' resume, 'q' shutdown" fullword ascii
      $s3 = "* THREADS:      %d, %s, aes=%d, hf=%zu, %sdonate=%d%%" fullword ascii
      $s4 = ".nicehash.com" ascii
   condition:
      uint16(0) == 0x457f and filesize < 8000KB and ( 1 of ($x*) or 2 of them )
}

rule SUSP_XMRIG_String {
   meta:
      description = "Detects a suspicious XMRIG crypto miner executable string in filr"
      author = "Florian Roth (Nextron Systems)"
      reference = "Internal Research"
      date = "2018-12-28"
      hash1 = "eb18ae69f1511eeb4ed9d4d7bcdf3391a06768f384e94427f4fc3bd21b383127"
      id = "8c6f3e6e-df2a-51b7-81b8-21cd33b3c603"
   strings:
      $x1 = "xmrig.exe" fullword ascii
   condition:
      uint16(0) == 0x5a4d and filesize < 2000KB and 1 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/pua_xmrig_monero_miner.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/vul_php_zlib_backdoor.yar | rules: 1 =====
rule VULN_PHP_Hack_Backdoored_Zlib_Zerodium_Mar21_1 {
   meta:
      description = "Detects backdoored PHP zlib version"
      author = "Florian Roth (Nextron Systems)"
      reference = "https://www.bleepingcomputer.com/news/security/phps-git-server-hacked-to-add-backdoors-to-php-source-code/"
      date = "2021-03-29"
      id = "5e0ab8f8-776a-52b0-b5be-ff1d34bccfd1"
   strings:
      $x1 = "REMOVETHIS: sold to zerodium, mid 2017" fullword ascii
      $x2 = "HTTP_USER_AGENTT" ascii fullword
   condition:
      filesize < 3000KB and
      all of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/vul_php_zlib_backdoor.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/vuln_erlang_otp_ssh_cve_2025_32433.yar | rules: 1 =====
rule VULN_Erlang_OTP_SSH_CVE_2025_32433_Apr25 {
   meta:
      description = "Detects binaries vulnerable to CVE-2025-32433 in Erlang/OTP SSH"
      author = "Pierre-Henri Pezier, Florian Roth"
      reference = "https://www.upwind.io/feed/cve-2025-32433-critical-erlang-otp-ssh-vulnerability-cvss-10"
      date = "2025-04-18"
      score = 60
   strings:
      $a1 = { 46 4F 52 31 ?? ?? ?? ?? 42 45 41 4D }

      $s1 = "ssh_connection.erl"

      $fix1 = "chars_limit"
      $fix2 = "allow    macro_log"
      $fix3 = "logger"
      $fix4 = "max_log_item_len"
   condition:
      filesize < 1MB
      and $a1 at 0 // BEAM file header
      and $s1
      and not 1 of ($fix*)
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/vuln_erlang_otp_ssh_cve_2025_32433.yar =====

// ===== BEGIN SOURCE: github:Neo23x0/signature-base:master:yara/webshell_regeorg.yar | rules: 1 =====
rule REGEORG_Tuneller_generic {
    meta:
        author = "Mandiant"
        date = "2021-12-20"
        date_modified = "2021-12-20"
        hash = "ba22992ce835dadcd06bff4ab7b162f9"
        reference = "https://www.mandiant.com/resources/unc3524-eye-spy-email"
        id = "a87979b7-2732-5a32-b3f3-a815a58b6589"
    strings:
        $s1 = "System.Net.IPEndPoint"
        $s2 = "Response.AddHeader"
        $s3 = "Request.InputStream.Read"
        $s4 = "Request.Headers.Get"
        $s5 = "Response.Write"
        $s6 = "System.Buffer.BlockCopy"
        $s7 = "Response.BinaryWrite"
        $s8 = "SocketException soex"
    condition:
        filesize < 1MB and 7 of them
}
// ===== END SOURCE: github:Neo23x0/signature-base:master:yara/webshell_regeorg.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/APT_EnergeticBear_backdoored_ssh.yar | rules: 1 =====
rule Backdoored_ssh {
meta:
author = "Kaspersky"
reference = "https://securelist.com/energetic-bear-crouching-yeti/85345/"
actor = "Energetic Bear/Crouching Yeti"
strings:
$a1 = "OpenSSH"
$a2 = "usage: ssh"
$a3 = "HISTFILE"
condition:
uint32(0) == 0x464c457f and filesize<1000000 and all of ($a*)
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/APT_EnergeticBear_backdoored_ssh.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxBew.yar | rules: 1 =====
rule LinuxBew: MALW
{
	meta:
		description = "Linux.Bew Backdoor"
		author = "Joan Soriano / @w0lfvan"
		date = "2017-07-10"
		version = "1.0"
		MD5 = "27d857e12b9be5d43f935b8cc86eaabf"
		SHA256 = "80c4d1a1ef433ac44c4fe72e6ca42395261fbca36eff243b07438263a1b1cf06"
	strings:
		$a = "src/secp256k1.c"
		$b = "hfir.u230.org"
		$c = "tempfile-x11session"
	condition:
		all of them
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxBew.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxHelios.yar | rules: 1 =====
rule LinuxHelios: MALW
{
	meta:
		description = "Linux.Helios"
		author = "Joan Soriano / @w0lfvan"
		date = "2017-10-19"
		version = "1.0"
		MD5 = "1a35193f3761662a9a1bd38b66327f49"
		SHA256 = "72c2e804f185bef777e854fe86cff3e86f00290f32ae8b3cb56deedf201f1719"
	strings:
		$a = "LIKE A GOD!!! IP:%s User:%s Pass:%s"
		$b = "smack"
		$c = "PEACE OUT IMMA DUP\n"
	condition:
		all of them
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxHelios.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxMoose.yar | rules: 2 =====
/*
    This Yara ruleset is under the GNU-GPLv2 license (http://www.gnu.org/licenses/gpl-2.0.html) and open to any user or organization, as    long as you use it under this license.

*/

// Linux/Moose yara rules
// For feedback or questions contact us at: github@eset.com
// https://github.com/eset/malware-ioc/
//
// These yara rules are provided to the community under the two-clause BSD
// license as follows:
//
// Copyright (c) 2015, ESET
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

private rule is_elf
{
    strings:
        $header = { 7F 45 4C 46 }

    condition:
        $header at 0
}

rule moose
{
    meta:
        Author      = "Thomas Dupuy"
        Date        = "2015/04/21"
        Description = "Linux/Moose malware"
        Reference   = "http://www.welivesecurity.com/wp-content/uploads/2015/05/Dissecting-LinuxMoose.pdf"
        Source = "https://github.com/eset/malware-ioc/"
        Contact = "github@eset.com"
        License = "BSD 2-Clause"

    strings:
        $s0 = "Status: OK"
        $s1 = "--scrypt"
        $s2 = "stratum+tcp://"
        $s3 = "cmd.so"
        $s4 = "/Challenge"
        $s7 = "processor"
        $s9 = "cpu model"
        $s21 = "password is wrong"
        $s22 = "password:"
        $s23 = "uthentication failed"
        $s24 = "sh"
        $s25 = "ps"
        $s26 = "echo -n -e "
        $s27 = "chmod"
        $s28 = "elan2"
        $s29 = "elan3"
        $s30 = "chmod: not found"
        $s31 = "cat /proc/cpuinfo"
        $s32 = "/proc/%s/cmdline"
        $s33 = "kill %s"

    condition:
        is_elf and all of them
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_LinuxMoose.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_Miscelanea_Linux.yar | rules: 7 =====
/*
    This Yara ruleset is under the GNU-GPLv2 license (http://www.gnu.org/licenses/gpl-2.0.html) and open to any user or organization, as    long as you use it under this license.

*/

import "pe"


rule LinuxAESDDoS
{
    meta:
	Author = "@benkow_"
	Date = "2014/09/12"
	Description = "Strings inside"
        Reference = "http://www.kernelmode.info/forum/viewtopic.php?f=16&t=3483"

    strings:
        $a = "3AES"
        $b = "Hacker"
        $c = "VERSONEX"

    condition:
        2 of them
}

rule LinuxBillGates 
{
    meta:
       Author      = "@benkow_"
       Date        = "2014/08/11" 
       Description = "Strings inside"
       Reference   = "http://www.kernelmode.info/forum/viewtopic.php?f=16&t=3429" 

    strings:
        $a= "12CUpdateGates"
        $b= "11CUpdateBill"

    condition:
        $a and $b
}

rule LinuxElknot
{
    meta:
	Author      = "@benkow_"
        Date        = "2013/12/24" 
        Description = "Strings inside"
        Reference   = "http://www.kernelmode.info/forum/viewtopic.php?f=16&t=3099"

    strings:
        $a = "ZN8CUtility7DeCryptEPciPKci"
	$b = "ZN13CThreadAttack5StartEP11CCmdMessage"

    condition:
	all of them
}

rule LinuxMrBlack
{
    meta:
	Author      = "@benkow_"
        Date        = "2014/09/12" 
        Description = "Strings inside"
        Reference   = "http://www.kernelmode.info/forum/viewtopic.php?f=16&t=3483"

    strings:
        $a = "Mr.Black"
	$b = "VERS0NEX:%s|%d|%d|%s"
    condition:
        $a and $b
}

rule LinuxTsunami
{
    meta:
	
		Author      = "@benkow_"
		Date        = "2014/09/12" 
		Description = "Strings inside"
		Reference   = "http://www.kernelmode.info/forum/viewtopic.php?f=16&t=3483"

    strings:
        $a = "PRIVMSG %s :[STD]Hitting %s"
        $b = "NOTICE %s :TSUNAMI <target> <secs>"
        $c = "NOTICE %s :I'm having a problem resolving my host, someone will have to SPOOFS me manually."
    condition:
        $a or $b or $c
}

rule rootkit
{
	meta:
                author="xorseed"
                reference= "https://stuff.rop.io/"
	strings:
		$sys1 = "sys_write" nocase ascii wide	
		$sys2 = "sys_getdents" nocase ascii wide
		$sys3 = "sys_getdents64" nocase ascii wide
		$sys4 = "sys_getpgid" nocase ascii wide
		$sys5 = "sys_getsid" nocase ascii wide
		$sys6 = "sys_setpgid" nocase ascii wide
		$sys7 = "sys_kill" nocase ascii wide
		$sys8 = "sys_tgkill" nocase ascii wide
		$sys9 = "sys_tkill" nocase ascii wide
		$sys10 = "sys_sched_setscheduler" nocase ascii wide
		$sys11 = "sys_sched_setparam" nocase ascii wide
		$sys12 = "sys_sched_getscheduler" nocase ascii wide
		$sys13 = "sys_sched_getparam" nocase ascii wide
		$sys14 = "sys_sched_setaffinity" nocase ascii wide
		$sys15 = "sys_sched_getaffinity" nocase ascii wide
		$sys16 = "sys_sched_rr_get_interval" nocase ascii wide
		$sys17 = "sys_wait4" nocase ascii wide
		$sys18 = "sys_waitid" nocase ascii wide
		$sys19 = "sys_rt_tgsigqueueinfo" nocase ascii wide
		$sys20 = "sys_rt_sigqueueinfo" nocase ascii wide
		$sys21 = "sys_prlimit64" nocase ascii wide
		$sys22 = "sys_ptrace" nocase ascii wide
		$sys23 = "sys_migrate_pages" nocase ascii wide
		$sys24 = "sys_move_pages" nocase ascii wide
		$sys25 = "sys_get_robust_list" nocase ascii wide
		$sys26 = "sys_perf_event_open" nocase ascii wide
		$sys27 = "sys_uname" nocase ascii wide
		$sys28 = "sys_unlink" nocase ascii wide
		$sys29 = "sys_unlikat" nocase ascii wide
		$sys30 = "sys_rename" nocase ascii wide
		$sys31 = "sys_read" nocase ascii wide
		$sys32 = "kobject_del" nocase ascii wide
		$sys33 = "list_del_init" nocase ascii wide
		$sys34 = "inet_ioctl" nocase ascii wide
	condition:
		9 of them
}

rule exploit
{
        meta:
                author="xorseed"
                reference= "https://stuff.rop.io/"
	strings:
		$xpl1 = "set_fs_root" nocase ascii wide
		$xpl2 = "set_fs_pwd" nocase ascii wide
		$xpl3 = "__virt_addr_valid" nocase ascii wide
		$xpl4 = "init_task" nocase ascii wide
		$xpl5 = "init_fs" nocase ascii wide
		$xpl6 = "bad_file_ops" nocase ascii wide
		$xpl7 = "bad_file_aio_read" nocase ascii wide
		$xpl8 = "security_ops" nocase ascii wide
		$xpl9 = "default_security_ops" nocase ascii wide
		$xpl10 = "audit_enabled" nocase ascii wide
		$xpl11 = "commit_creds" nocase ascii wide
		$xpl12 = "prepare_kernel_cred" nocase ascii wide
		$xpl13 = "ptmx_fops" nocase ascii wide
		$xpl14 = "node_states" nocase ascii wide
	condition:
		7 of them
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_Miscelanea_Linux.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_Monero_Miner_installer.yar | rules: 1 =====
rule nkminer_monero {

 meta:

 description = "Detects installer of Monero miner that points to a NK domain"

 author = "cdoman@alienvault.com"
 
 reference = "https://www.alienvault.com/blogs/labs-research/a-north-korean-monero-cryptocurrency-miner"

 tlp = "white"

 license = "MIT License"

 strings:

 $a = "82e999fb-a6e0-4094-aa1f-1a306069d1a5" nocase wide ascii

 $b = "4JUdGzvrMFDWrUUwY3toJATSeNwjn54LkCnKBPRzDuhzi5vSepHfUckJNxRL2gjkNrSqtCoRUrEDAgRwsQvVCjZbRy5YeFCqgoUMnzumvS" nocase wide ascii

 $c = "barjuok.ryongnamsan.edu.kp" nocase wide ascii

 $d = "C:\\SoftwaresInstall\\soft" nocase wide ascii

 $e = "C:\\Windows\\Sys64\\intelservice.exe" nocase wide ascii

 $f = "C:\\Windows\\Sys64\\updater.exe" nocase wide ascii

 $g = "C:\\Users\\Jawhar\\documents\\" nocase wide ascii

 condition:

 any of them

}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_Monero_Miner_installer.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:malware/MALW_XMRIG_Miner.yar | rules: 1 =====
rule XMRIG_Miner
{
	meta:
  ref = "https://gist.github.com/GelosSnake/c2d4d6ef6f93ccb7d3afb5b1e26c7b4e"
  strings:
    $a1 = "stratum+tcp"
    condition:
    $a1  
}
// ===== END SOURCE: github:Yara-Rules/rules:master:malware/MALW_XMRIG_Miner.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:webshells/WShell_ChinaChopper.yar | rules: 2 =====
/*
    This Yara ruleset is under the GNU-GPLv2 license (http://www.gnu.org/licenses/gpl-2.0.html) and open to any user or organization, as long as you use it under this license.
*/

rule webshell_ChinaChopper_aspx
{
  meta:
    author      = "Ryan Boyle randomrhythm@rhythmengineering.com"
    date        = "2020/10/28"
    description = "Detect China Chopper ASPX webshell"
    reference1  = "https://www.fireeye.com/blog/threat-research/2013/08/breaking-down-the-china-chopper-web-shell-part-i.html"
    filetype    = "aspx"
  strings:
	$ChinaChopperASPX = {25 40 20 50 61 67 65 20 4C 61 6E 67 75 61 67 65 3D ?? 4A 73 63 72 69 70 74 ?? 25 3E 3C 25 65 76 61 6C 28 52 65 71 75 65 73 74 2E 49 74 65 6D 5B [1-100] 75 6E 73 61 66 65}
  condition:
	$ChinaChopperASPX
}

rule webshell_ChinaChopper_php
{
  meta:
    author      = "Ryan Boyle randomrhythm@rhythmengineering.com"
    date        = "2020/10/29"
    description = "Detect China Chopper PHP webshell"
    reference1  = "https://www.fireeye.com/blog/threat-research/2013/08/breaking-down-the-china-chopper-web-shell-part-i.html"
    filetype    = "php"
  strings:
	$ChinaChopperPHP = {3C 3F 70 68 70 20 40 65 76 61 6C 28 24 5F 50 4F 53 54 5B ?? 70 61 73 73 77 6F 72 64 ?? 5D 29 3B 3F 3E}
  condition:
	$ChinaChopperPHP
}
// ===== END SOURCE: github:Yara-Rules/rules:master:webshells/WShell_ChinaChopper.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:webshells/WShell_Drupalgeddon2_icos.yar | rules: 1 =====
/*
This Yara ruleset is under the GNU-GPLv2 license 
(http://www.gnu.org/licenses/gpl-2.0.html) and open to any user or 
organization, as long as you use it under this license.
*/

/*
Author: Luis Fueris 
Date: 4 october, 2019
Description: Drupalgeddon 2 - Web Shells Extract. This rules matchs with
webshells that inserts the Drupal core vulnerability SA-CORE-2018-002 
(https://www.drupal.org/sa-core-2018-002)
*/

rule Dotico_PHP_webshell : webshell {
    meta:
        description = ".ico PHP webshell - file <eight-num-letter-chars>.ico"
        author = "Luis Fueris"
        reference = "https://rankinstudio.com/Drupal_ico_index_hack"
        date = "2019/12/04"
    strings:
        $php = "<?php" ascii
        $regexp = /basename\/\*[a-z0-9]{,6}\*\/\(\/\*[a-z0-9]{,5}\*\/trim\/\*[a-z0-9]{,5}\*\/\(\/\*[a-z0-9]{,5}\*\//
    condition:
        $php at 0 and $regexp and filesize > 70KB and filesize < 110KB
}
// ===== END SOURCE: github:Yara-Rules/rules:master:webshells/WShell_Drupalgeddon2_icos.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:webshells/WShell_PHP_Anuna.yar | rules: 1 =====
/*
    I first found this in May 2016, appeared in every PHP file on the
    server, cleaned it with `sed` and regex magic. Second time was
    in June 2016, same decoded content, different encoding/naming.

    https://www.symantec.com/security_response/writeup.jsp?docid=2015-111911-4342-99
*/
rule php_anuna
{
    meta:
        author      = "Vlad https://github.com/vlad-s"
        date        = "2016/07/18"
        description = "Catches a PHP Trojan"
    strings:
        $a = /<\?php \$[a-z]+ = '/
        $b = /\$[a-z]+=explode\(chr\(\([0-9]+[-+][0-9]+\)\)/
        $c = /\$[a-z]+=\([0-9]+[-+][0-9]+\)/
        $d = /if \(!function_exists\('[a-z]+'\)\)/
    condition:
        all of them
}
// ===== END SOURCE: github:Yara-Rules/rules:master:webshells/WShell_PHP_Anuna.yar =====

// ===== BEGIN SOURCE: github:Yara-Rules/rules:master:webshells/WShell_PHP_in_images.yar | rules: 1 =====
/*
    Finds PHP code in JP(E)Gs, GIFs, PNGs.
    Magic numbers via Wikipedia.
*/
rule php_in_image
{
    meta:
        author      = "Vlad https://github.com/vlad-s"
        date        = "2016/07/18"
        description = "Finds image files w/ PHP code in images"
    strings:
        $gif = /^GIF8[79]a/
        $jfif = { ff d8 ff e? 00 10 4a 46 49 46 }
        $png = { 89 50 4e 47 0d 0a 1a 0a }

        $php_tag = "<?php"
    condition:
        (($gif at 0) or
        ($jfif at 0) or
        ($png at 0)) and

        $php_tag
}
// ===== END SOURCE: github:Yara-Rules/rules:master:webshells/WShell_PHP_in_images.yar =====
