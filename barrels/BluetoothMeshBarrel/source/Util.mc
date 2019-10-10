using Toybox.System;
using Toybox.Lang;
using Toybox.Cryptography as Crypto;

module BluetoothMeshBarrel {

    const BLOCK_SIZE = 16;

    enum {
        MIC_SIZE_4,
        MIC_SIZE_8
    }

    // based off of https://github.com/conz27/crypto-test-vectors/blob/master/aesccm.py
    // Thank you for the help!!!!! At some point in the future, may need to go back and
    // add support for the adata field...
    // @param key ByteArray Represents the key for encryption.
    // @param data ByteArray The data to encrypt.
    // @param nonce ByteArray The nonce to encrypt the data with.
    // @param micSize Number The desired output MIC size in bytes.
    // @return [ByteArray] The encrypted data.
    function aes_ccm_enc(key, data, nonce, micSize) {
        // create B_0 block for CMAC authentication
        var myData = pad(copy(data));

        var mprime = ((micSize + 1) * 4 - 2)/2;
        var loctets = 15 - nonce.size();
        var lprime = loctets - 1;
        var B_0 = [8*mprime + lprime]b;
        B_0.addAll(nonce);

        for (var i = loctets - 1; i >= 0; i--) {
            B_0.add((data.size() >> (i * 8)) & 0xff);
        }

        // calculate CMAC authentication code
        var aes = new Crypto.Cipher({:algorithm => Crypto.CIPHER_AES128, :mode => Crypto.MODE_ECB, :key => key});

        var T = aes.encrypt(B_0);
        for (var i = 0; i < myData.size(); i += BLOCK_SIZE) {
            var B_i = myData.slice(i, i + BLOCK_SIZE);
            var xor_out = new [BLOCK_SIZE]b;
            for (var j = 0; j < B_i.size(); j++) {
                xor_out[j] = B_i[j] ^ T[j];
            }
            T = aes.encrypt(xor_out);
        }

        // create A_0 block for CTR encryption
        var counter = 0;
        var A_base = [lprime]b;
        A_base.addAll(nonce);

        var A_0 = copy(A_base);
        for (var i = loctets - 1; i >= 0; i--) {
            A_0.add((counter >> (i * 8)) & 0xff);
        }
        counter++;

        // calculate the MIC
        var S_0 = aes.encrypt(A_0);
        var U = new [BLOCK_SIZE];
        for (var i = 0; i < U.size(); i++) {
            U[i] = T[i] ^ S_0[i];
        }
        U = U.slice(0, (micSize + 1) * 4);


        // perform CTR encryption
        var C = []b;
        for (var i = 0; i < myData.size(); i += BLOCK_SIZE) {
            var A_i = copy(A_base);
            for (var j = loctets - 1; j >= 0; j--) {
                A_i.add((counter >> (j * 8)) & 0xff);
            }
            var S_i = aes.encrypt(A_i);
            var B_i = myData.slice(i, i + BLOCK_SIZE);
            var C_i = new [BLOCK_SIZE]b;
            for (var j = 0; j < B_i.size(); j++) {
                C_i[j] = B_i[j] ^ S_i[j];
            }
            C.addAll(C_i);
            counter++;
        }

        C = C.slice(0, data.size());
        C.addAll(U);
        return C;
    }

    // based off of https://github.com/conz27/crypto-test-vectors/blob/master/aesccm.py
    // Thank you for the help!!!!! At some point in the future, may need to go back and
    // add support for the adata field...
    // @param key ByteArray Represents the key for encryption.
    // @param data ByteArray The data to decrypt.
    // @param nonce ByteArray The nonce to decrypt the data with.
    // @param micSize Number The known MIC size in bytes.
    // @return [ByteArray] The plaintext data.
    function aes_ccm_dec(key, data, nonce, micSize) {

        var U = data.slice(-4 * (micSize + 1), null);
        var C = data.slice(0, -4 * (micSize + 1));
        var myData = pad(copy(C));

        var mprime = ((micSize + 1) * 4 - 2)/2;
        var loctets = 15 - nonce.size();
        var lprime = loctets - 1;

        var aes = new Crypto.Cipher({:algorithm => Crypto.CIPHER_AES128, :mode => Crypto.MODE_ECB, :key => key});

        // retrieve A_0 block for CTR decryption
        var counter = 0;
        var A_base = [lprime]b;
        A_base.addAll(nonce);

        var A_0 = copy(A_base);
        for (var i = loctets - 1; i >= 0; i--) {
            A_0.add((counter >> (i * 8)) & 0xff);
        }
        counter++;

        // retrieve the CMAC value T
        // If the nonce is not 13 bytes, this here will throw a random exception.
        // So if you are reading this you probably have an invalid nonce
        // TODO: add error checking for invalid nonce size
        var S_0 = aes.encrypt(A_0);
        var T = new [(micSize + 1) * 4];
        for (var i = 0; i < U.size(); i++) {
            T[i] = U[i] ^ S_0[i];
        }

        // perform CTR decryption
        var P = []b;
        for (var i = 0; i < myData.size(); i += BLOCK_SIZE) {
            var A_i = copy(A_base);
            for (var j = loctets - 1; j >= 0; j--) {
                A_i.add((counter >> (j * 8)) & 0xff);
            }
            var S_i = aes.encrypt(A_i);
            var C_i = myData.slice(i, i + BLOCK_SIZE);
            var P_i = new [BLOCK_SIZE]b;
            for (var j = 0; j < C_i.size(); j++) {
                P_i[j] = C_i[j] ^ S_i[j];
            }
            P.addAll(P_i);
            counter++;
        }
        P = P.slice(0, C.size());
        myData = pad(copy(P));

        // calculate the CMAC in same way
        var B_0 = [8*mprime + lprime]b;
        B_0.addAll(nonce);

        for (var i = loctets - 1; i >= 0; i--) {
            B_0.add((P.size() >> (i * 8)) & 0xff);
        }

        var T_confirm = aes.encrypt(B_0);
        for (var i = 0; i < myData.size(); i += BLOCK_SIZE) {
            var B_i = myData.slice(i, i + BLOCK_SIZE);
            var xor_out = new [BLOCK_SIZE]b;
            for (var j = 0; j < B_i.size(); j++) {
                xor_out[j] = B_i[j] ^ T_confirm[j];
            }
            T_confirm = aes.encrypt(xor_out);
        }

        for (var i = 0; i < T.size(); i++) {
            if (T_confirm[i] != T[i]) {
                return null;
            }
        }

        return P;
    }

    // Implements the s1 function as defined in the Bluetooth Mesh
    // specification document.
    // @param p Non-zero length ByteArray used in salt generation.
    // @return [ByteArray] Generated 128 bit salt.
    function s1(p) {
        var zeros = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]b;
        return aes_cmac(p, zeros);
    }

    // Implements the k1 function as defined in the Bluetooth Mesh
    // specification document.
    // @param n ByteArray with length of 0 or more bytes.
    // @param salt 128 bit ByteArray.
    // @param p ByteArray with length of 0 or more bytes.
    // @return [ByteArray] 16 byte output of k1 function.
    function k1(n, salt, p) {
        var t = aes_cmac(n, salt);
        return aes_cmac(p, t);
    }

    // Implements the k2 function as defined in the Bluetooth Mesh
    // specification document.
    // @param n 128 bit ByteArray.
    // @param p ByteArray with length of 1 or more bytes.
    // @return [ByteArray] 33 byte output of k2 function.
    function k2(n, p) {
        var salt = s1([0x73, 0x6d, 0x6b, 0x32]b);
        var t = aes_cmac(n, salt);
        var t1 = aes_cmac(copy(p).add(0x01), t);
        var t2 = aes_cmac(copy(t1).addAll(p).add(0x02), t);
        var t3 = aes_cmac(copy(t2).addAll(p).add(0x03), t);
        var output = copy(t1);
        output.addAll(t2);
        output.addAll(t3);
        output = output.slice(-33, null);
        output[0] = output[0] & 0x7f;
        return output;
    }

    // Implements the k3 function as defined in the Bluetooth Mesh
    // specification document.
    // @param n 128 bit ByteArray
    // @return [ByteArray] 8 byte output of k3 function.
    function k3(n) {
        var salt = s1([0x73, 0x6d, 0x6b, 0x33]b);
        var t = aes_cmac(n, salt);
        var output = aes_cmac([0x69, 0x64, 0x36, 0x34, 0x01]b, t);
        return output.slice(-8, null);
    }

    // Implements the k4 function as defined in the Bluetooth Mesh
    // specification document.
    // @param n 128 bit ByteArray
    // @return [Number] 6 bit output of k4 function.
    function k4(n) {
        var salt = s1([0x73, 0x6d, 0x6b, 0x34]b);
        var t = aes_cmac(n, salt);
        var output = aes_cmac([0x69, 0x64, 0x36, 0x01]b, t);
        return output[output.size() - 1] & 0x3f;
    }

    // Implements the AES-CMAC function as defined in the Bluetooth Mesh
    // specification document.
    // @param m Variable-length ByteArray data.
    // @param k 128 bit ByteArray key.
    // @return [ByteArray] The calculated MAC.
    function aes_cmac(m, k) {
        var cmac = new Crypto.CipherBasedMessageAuthenticationCode({:algorithm => Crypto.CIPHER_AES128, :key => k});
        cmac.update(m);
        return cmac.digest();
    }

    // Implements the aes encryption functionality.
    // @param key 128 bit ByteArray key.
    // @param data The variable-length ByteArray data to encrypt.
    // @return [ByteArray] The encrypted data.
    function aes(key, data) {
        var aes = new Crypto.Cipher({:algorithm => Crypto.CIPHER_AES128, :mode => Crypto.MODE_ECB, :key => key});
        return aes.encrypt(data);
    }

    // Copies data to a new ByteArray
    // @param bytes ByteArray The source data.
    // @return [ByteArray] The copied data.
    function copy(bytes) {
        var myData = []b;
        myData.addAll(bytes);
        return myData;
    }

    // Pads a block of data with zeros if not enough.
    // WARNING: MUTATES THE INPUT.
    // @param bytes ByteArray The source data to pad.
    // @return [ByteArray] The padded data.
    function pad(bytes) {
        while (bytes.size() % BLOCK_SIZE != 0) {
            bytes.add(0x00);
        }
        return bytes;
    }

    // Converts a Number to ByteArray of the specified size
    // @param value Number The target number to convert to a ByteArray
    // @param size Number The number of bytes of the output
    // @return [ByteArray] The big-endian bytes representation of the input
    function toBytes(value, size) {
        var bytes = new [size]b;
        for (var i = 0; i < size; i++) {
            bytes[i] = (value >> ((size - i - 1) * 8)) & 0xff;
        }
        return bytes;
    }

    function toBytesLittleEndian(value, size) {
        var bytes = new [size]b;
        for (var i = 0; i < size; i++) {
            bytes[i] = (value >> (i * 8)) & 0xff;
        }
        return bytes;
    }

    // Converts a ByteArray to a Number of the specified size
    // @param data ByteArray The target array to convert to a Number
    // @param size Number The number of bytes of the output
    // @return [Number] The big-endian interpretation of the input
    function fromBytes(data, offset, size) {
        var value = size > 4 ? 0l : 0;
        for (var i = size; i > 0; i--) {
            value += (data[offset + size - i] << (8 * (i - 1)));
        }
        return value;
    }

    function fromBytesLittleEndian(data, offset, size) {
        var value = size > 4 ? 0l : 0;
        for (var i = 0; i < size; i++) {
            value += (data[offset + i] << (8 * i));
        }
        return value;
    }

    // Formats a ByteArray as a hexadecimal string (for debugging).
    // @param bytes ByteArray The source data.
    // @param digits Number The number of hexadecimal digits in a word (null for one continuous string).
    // @return [String] Representation of the ByteArray as a hexadecimal string.
    function hexString(bytes, digits) {
        if (digits == null) {
            digits = bytes.size();
        }
        var str = "0x";
        for (var i = 0; i < bytes.size(); i++) {
            if (i != 0 && (i % digits) == 0) {
                str += " 0x";
            }
            str += bytes[i].format("%02x");
        }
        return str;
    }

}