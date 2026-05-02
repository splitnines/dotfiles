include "/home/rickey/dotfiles/yara/.local/share/yara/linux_persistence_hunt_nightly_focused.yar"

/*
  Weekly balanced add-ons.
  Intent: scan noisier areas with stronger evidence requirements.
*/

rule Weekly_ELF_XMRig_Miner_Strict
{
    meta:
        description = "XMRig-like miner strings in ELF executable"
        severity = "medium"
        cadence = "weekly"

    strings:
        $s1 = "'h' hashrate, 'p' pause, 'r' resume" ascii
        $s2 = "--cpu-affinity" ascii
        $s3 = "password for mining server" ascii
        $s4 = "XMRig/" ascii
        $s5 = "stratum+tcp" ascii
        $s6 = "stratum+udp" ascii

    condition:
        uint32(0) == 0x464c457f and filesize < 20MB and 2 of them
}

rule Weekly_ELF_Ransomware_HelloKitty_Strict
{
    meta:
        description = "HelloKitty Linux ransomware strings in ELF"
        severity = "high"
        cadence = "weekly"

    strings:
        $v1 = "esxcli vm process kill -t=force -w=%d" ascii
        $v2 = "error encrypt: %s rename back:%s" ascii
        $v3 = "Total VM run on host:" ascii
        $v4 = "Mode:%d  Verbose:%d Daemon:%d AESNI:%d RDRAND:%d " ascii
        $v5 = "ChaCha20 for x86_64, CRYPTOGAMS by <appro@openssl.org>" ascii

    condition:
        uint32(0) == 0x464c457f and filesize < 2MB and 4 of them
}

rule Weekly_ELF_LinaDoor_Rootkit_Strict
{
    meta:
        description = "LinaDoor rootkit strings in ELF"
        severity = "high"
        cadence = "weekly"

    strings:
        $s1 = "/dev/net/.../rootkit_/" ascii
        $s2 = "did_exec" ascii fullword
        $s3 = "rh_reserved_tp_target" ascii fullword
        $s4 = "HIDDEN_SERVICES" ascii fullword
        $s5 = "bypass_udp_ports" ascii fullword
        $s6 = "DoBypassIP" ascii fullword

    condition:
        uint32(0) == 0x464c457f and filesize < 5MB and 3 of them
}

rule Weekly_ELF_Kernel_Exploit_Strings_Strict
{
    meta:
        description = "Kernel exploit/rootkit symbol cluster in ELF"
        severity = "medium"
        cadence = "weekly"

    strings:
        $x1 = "commit_creds" ascii wide
        $x2 = "prepare_kernel_cred" ascii wide
        $x3 = "init_task" ascii wide
        $x4 = "init_fs" ascii wide
        $x5 = "ptmx_fops" ascii wide
        $x6 = "security_ops" ascii wide
        $x7 = "default_security_ops" ascii wide
        $x8 = "__virt_addr_valid" ascii wide

    condition:
        uint32(0) == 0x464c457f and filesize < 10MB and 5 of them
}

   rule Weekly_SSH_Private_Key_Exfil_Strict
   {
       meta:
           description = "SSH private key exfiltration-like command syntax"
           severity = "high"
           cadence = "weekly"

       strings:
           $curl_t = /curl\s+[^\n]{0,120}(-T|--upload-file|-F|--form|--data|--data-binary)[^\n]{0,200}\.ssh\/id_(rsa|ed25519|ecdsa)\b/ nocase
           $wget_post = /wget\s+[^\n]{0,120}--post-file[=\s][^\n]{0,200}\.ssh\/id_(rsa|ed25519|ecdsa)\b/ nocase
           $nc_redir = /(nc|ncat|socat)\b[^\n]{0,200}<\s*[~\/A-Za-z0-9._-]*\.ssh\/id_(rsa|ed25519|ecdsa)\b/ nocase
           $scp_remote = /scp\s+[^\n]{0,160}\.ssh\/id_(rsa|ed25519|ecdsa)\b[^\n]{0,160}[A-Za-z0-9._-]+@[A-Za-z0-9._-]+:/ nocase
           $rsync_remote = /rsync\s+[^\n]{0,160}\.ssh\/id_(rsa|ed25519|ecdsa)\b[^\n]{0,160}[A-Za-z0-9._-]+@[A-Za-z0-9._-]+:/ nocase

       condition:
           any of them
   }
