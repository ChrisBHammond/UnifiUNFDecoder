# Found most of this info at 
# https://community.ubnt.com/t5/UniFi-Wireless/unf-controller-backup-file-format/td-p/1624105

# Many thanks to this git repo for the key and basic logic! https://github.com/zhangyoufu/unifi-backup-decrypt
# Also AES credit: https://gist.github.com/ctigeek/2a56648b923d198a6e60
#Output will be a tar.gz in same directory as your initial file. Use your favorite archive tool to open, such as 7-zip.
function Create-AesManagedObject($key, $IV) {
    $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
    $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
    $aesManaged.BlockSize = 128
    $aesManaged.KeySize = 256
    if ($IV) {
        if ($IV.getType().Name -eq "String") {
            $aesManaged.IV = [System.Convert]::FromBase64String($IV)
        }
        else {
            $aesManaged.IV = $IV
        }
    }
    if ($key) {
        if ($key.getType().Name -eq "String") {
            $aesManaged.Key = [System.Convert]::FromBase64String($key)
        }
        else {
            $aesManaged.Key = $key
        }
    }
    $aesManaged
}

function Create-AesKey() {
    $aesManaged = Create-AesManagedObject
    $aesManaged.GenerateKey()
    [System.Convert]::ToBase64String($aesManaged.Key)
}

function Encrypt-String($key, $unencryptedString) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($unencryptedString)
    $aesManaged = Create-AesManagedObject $key
    $encryptor = $aesManaged.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($bytes, 0, $bytes.Length);
    [byte[]] $fullData = $aesManaged.IV + $encryptedData
    $aesManaged.Dispose()
    [System.Convert]::ToBase64String($fullData)
}

function Decrypt-String($key, $encryptedStringWithIV) {
    $bytes = [System.Convert]::FromBase64String($encryptedStringWithIV)
    $IV = $bytes[0..15]
    $aesManaged = Create-AesManagedObject $key $IV
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($bytes, 16, $bytes.Length - 16);
    $aesManaged.Dispose()
    [System.Text.Encoding]::UTF8.GetString($unencryptedData).Trim([char]0)
}


# The stats and configuration databases are BSON (Binary JSON) format. MongoDB comes with a `bsondump` tool that can #convert them to plain old JSON by running `bsondump db > db.json`. After doing that, I was able to parse these #databases with any JSON tool or script.

	#Change this path to your UNF file.
    $fullpath = "C:\temp\5.10.19-20190320-2118.unf"
    $encryptedstring = get-content $fullpath -Encoding Byte
    $outfile = $fullpath.Replace('.unf','.tar.gz')
    $key = [system.text.encoding]::UTF8.GetBytes("bcyangkmluohmars")

    $iv = [system.text.encoding]::UTF8.GetBytes("ubntenterpriseap")
    $aesManaged = Create-AesManagedObject -key $key -IV $iv
    $decryptor = $aesManaged.CreateDecryptor();
    $unencryptedData = $decryptor.TransformFinalBlock($encryptedstring, 16, $encryptedstring.Length - 16)
    $aesManaged.Dispose()

    [io.file]::WriteAllBytes($outfile,$unencryptedData)

