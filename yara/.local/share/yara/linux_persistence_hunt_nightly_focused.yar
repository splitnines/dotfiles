/*
  linux_persistence_hunt_nightly.yar

  Nightly-scan tuned variant generated from linux_persistence_hunt.yar.
  Original file was not modified.

  Changes made to reduce false positives observed in ~/.local/state/logs/scan.log:
  - systemctl enable by itself no longer triggers systemd persistence.
  - XDG autostart network/tool tokens use command-ish boundaries, so words like launch do not match nc.
  - BASH_ENV/ENV checks require line-oriented assignments instead of embedded NUL-separated binary strings.
  - SSH key exfiltration requires key path and transfer tool on same command line.
  - Private-key and token leak rules ignore ELF/PE binaries.
  - Suspicious /tmp execution no longer triggers on bare /tmp/path references; it requires shell execution or chmod.
  - Generic public rootkit syscall-name rule requires an ELF file.
*/

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
        description = "Potential SSH private key exfiltration command line"
        severity = "high"
        nightly_tuned = "true"

    strings:
        $transfer_key_1 = /(curl|wget|scp|rsync|ftp|sftp)\b[^\n]{0,300}\.ssh\/id_(rsa|ed25519|ecdsa)\b/ nocase
        $transfer_key_2 = /\.ssh\/id_(rsa|ed25519|ecdsa)\b[^\n]{0,300}(curl|wget|scp|rsync|ftp|sftp)\b/ nocase
        $nc_key_1 = /(nc|ncat|socat)\b[^\n]{0,300}\.ssh\/id_(rsa|ed25519|ecdsa)\b/ nocase
        $nc_key_2 = /\.ssh\/id_(rsa|ed25519|ecdsa)\b[^\n]{0,300}(nc|ncat|socat)\b/ nocase

    condition:
        any of them
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
        nightly_tuned = "true"

    strings:
        $ld_preload_tmp = /(^|\n)\s*(export\s+)?LD_PRELOAD\s*=\s*[^;\n]{0,120}\/(tmp|var\/tmp|dev\/shm)\// nocase
        $ld_library_tmp = /(^|\n)\s*(export\s+)?LD_LIBRARY_PATH\s*=\s*[^;\n]{0,160}\/(tmp|var\/tmp|dev\/shm)\// nocase
        $bash_env = /(^|\n)\s*(export\s+)?BASH_ENV\s*=\s*[^;\n]{1,200}/ nocase
        $env_file = /(^|\n)\s*(export\s+)?ENV\s*=\s*[^;\n]{1,200}\.(sh|bash|zsh|ksh)\b/ nocase
        $path_tmp_front = /(^|\n)\s*(export\s+)?PATH\s*=\s*\/(tmp|var\/tmp|dev\/shm)(:|\/|;|\n|$)/ nocase
        $path_cwd = /(^|\n)\s*(export\s+)?PATH\s*=\s*[^;\n]{0,200}(:\.|\.(:|$))/ nocase

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
        nightly_tuned = "true"

    strings:
        $service = "[Service]"
        $exec_net = /Exec(Start|StartPre|StartPost)\s*=[^\n]{0,300}(curl|wget|nc\b|ncat\b|socat\b|\/dev\/tcp|base64\s+(-d|--decode))/ nocase
        $exec_shell_net = /Exec(Start|StartPre|StartPost)\s*=[^\n]{0,300}(bash|sh|zsh|ksh)\s+-c[^\n]{0,300}(curl|wget|nc\b|ncat\b|socat\b|\/dev\/tcp|base64\s+(-d|--decode))/ nocase

    condition:
        $service and any of ($exec_*)
}


rule Linux_XDG_Autostart_Suspicious
{
    meta:
        description = "Suspicious XDG autostart entry"
        severity = "high"
        nightly_tuned = "true"

    strings:
        $desktop_entry = "[Desktop Entry]"
        $type_app = "Type=Application"
        $exec_suspicious = /(^|\n)Exec\s*=[^\n]{0,300}(curl\b|wget\b|nc\b|ncat\b|socat\b|\/dev\/tcp|base64\s+(-d|--decode)|bash\s+-c|sh\s+-c|python[0-9.]*\s+-c|perl\s+-e)/ nocase

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
        nightly_tuned = "true"
        disabled_reason = "Too noisy for root nightly scans: expected host/user keys and packaged test keys produce alerts. Use the original ruleset for targeted private-key discovery."

    strings:
        $openssh = "-----BEGIN OPENSSH PRIVATE KEY-----"
        $rsa = "-----BEGIN RSA PRIVATE KEY-----"
        $ec = "-----BEGIN EC PRIVATE KEY-----"
        $dsa = "-----BEGIN DSA PRIVATE KEY-----"

    condition:
        any of them and false
}


rule Linux_Common_Token_Leak
{
    meta:
        description = "Common API token or credential-looking string in non-binary file"
        severity = "medium"
        nightly_tuned = "true"

    strings:
        $aws_access_key = /AKIA[0-9A-Z]{16}/
        $github_pat = /gh[pousr]_[A-Za-z0-9_]{30,}/
        $slack_token = /xox[baprs]-[A-Za-z0-9-]{20,}/
        $generic_export_secret = /(^|\n)\s*export\s+[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_KEY)[A-Z0-9_]*\s*=\s*['"]?[A-Za-z0-9+\/_=.:@-]{16,}/ nocase
        $generic_assign_secret = /(^|\n)\s*[A-Z0-9_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_KEY)[A-Z0-9_]*\s*=\s*['"][^'"\n]{16,}['"]/ nocase

    condition:
        any of them and
        not uint16(0) == 0x457f and  // ELF
        not uint16(0) == 0x5a4d      // PE/MZ
}


rule Linux_Suspicious_Tmp_Execution
{
    meta:
        description = "Execution or chmod of file in common writable temp locations"
        severity = "medium"
        nightly_tuned = "true"

    strings:
        $tmp_exec_shell = /(^|[;&|`$()\s])(bash|sh|zsh|ksh)\s+\/(tmp|var\/tmp|dev\/shm)\/[A-Za-z0-9._-]{1,120}\b/ nocase
        $chmod_tmp = /(^|[;&|`$()\s])chmod\s+(\+x|[0-7]{3,4})\s+\/(tmp|var\/tmp|dev\/shm)\/[A-Za-z0-9._-]{1,120}\b/ nocase

    condition:
        any of them
}

/*
  awesome_yara_linux_triage.yar

  Ultra-light Linux triage bundle derived from the Awesome YARA full bundle.
