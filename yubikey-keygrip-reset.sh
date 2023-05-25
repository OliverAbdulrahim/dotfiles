# When a YubiKey with a GPG private key is inserted,
# gpg inserts a keygrip for each pk in the private-keys-v1.d directory
#
# Later, when you insert another YubiKey with the same private key,
# any attempted use of that key will be rejected with the following error:
# "Please insert card with serial number <the serial number of the first YubiKey>"
#
# To circumvent this, this script will:
#   - delete the keygrips, which are like stubs of the pk, sourced from the first YubiKey
#   - restart gpg-agent, which is needed to regenerate the private-keys dir
#   - source keys from the new YubiKey
#
# This script requires:
#   - YubiKeys with duplicate GPG keys
#   - ⚠️  you **must** have all your private keys on your YubiKeys
#   - ⚠️  again, this script deletes **all your locally-stored private keys**!
#   - your YubiKey that causes the "insert card with serial number" error message plugged in
#
# You'll have to run this script each time you plug in a different YubiKey!
#
# For more information, please see the following link:
# https://security.stackexchange.com/a/223055
rm -r ~/.gnupg/private-keys-v1.d
gpgconf --kill gpg-agent
gpg --card-status
