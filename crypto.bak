unit crypto
        (* this unit implements cryptography using 2 simple-ish systems known as RSA and ElGamal (cyclic group)  *)

        (* the lowering of the possible options to search by having kH focused multi algorithm keys does apparently
        reduse the the essential security of the methods. this apparent insecurity is purely a matter of raising
        the key size. the fact that an interpolation (1 bit stylee) manugactures with an IDEA (multi key mix)
        to provide good security on another key, or key set. multi session archives can benefit from the pattern
        of digitally keying the algorithm interpolation determinacy. also (in reverse), the choice of two decodings,
        one of which is correct, produce a subcode bitstream. approximating the "over key" as an algorithm switch,
        does allow the full cryptographic advantage of a key bit size. this is called postamble dominance crypto. *)

        (* this file does not do half of the above. it's a foundation modelling unit. the minimal key entity minima
        is bulk amplified via array. to detactch the two algorithms too much via another key value, is wasting the
        arrayed by over key, key switching efficiency. but that's another unit. *)

        uses modulo;
{$H+}
interface
        (* all strings are base64 encoded. larger strings must be split before crypto is used. *)
        type
                (* i seem to have this as little endian cardinal ordering *)
                key = record
                        (* public *)
                        kModulus: value; (* q *)
                        kCrypt: value; (* g *) (* this must be both coprime to kModulus and phi(kModulus) *)
                        kH: value; (* ElGamal g^x mod q => rsa public key signed *)

                        (* private *)
                        rsa: boolean; (* true? *)
                        kDecrypt: value; (* x *) (* in rsa, uses lcm((p-1)(q-1)) method => more x choices *)
                        kPhi: value; (* phi of the modulus, needed for ElGamal signatures *)
                end;

                quad = array [0 .. 3] of value;

        (* key and general encryption fiunctions *)
        function encrypt(a: value, k: key): quad; (* public *)
        function decrypt(a: quad, k: key): value; (* private *)
        function sign(a: value, k: key): quad;
        function check(a: quad, k: key, b: value): boolean;

        function loadPubKey(s: quad): key;
        function savePubKey(k; key): quad;
        function loadPrivKey(s: quad): key;
        function savePrivKey(k: key): quad;
        function createKey: key;
        function makePrime: value;

implementation
        function randomz(a: value, sig: boolean): value;
        var
                i: integer;
        begin
                randomize;
                for i = 0 to upper-1 do
                        randomz[i] := randomz[i] xor random(cardinal(not 0));
                randomz[upper] := 0; (* botch *)
                if sig then randomz = zero; (* more optimal or just random *)
        end;

        function makePrime: value;
        begin

        end;

        function createKey: key;
        begin

        end;

        function encryptt(a: value, k: key, sig: boolean): pair; (* public *)
        var
                t: value;
        begin
                setModulus(k.kModulus);
                if k.rsa then
                begin
                        if sig then t := k.kCrypt else t := k.kDecrypt;
                        encryptt[0] := power(a, t);
                        encryptt[1] := power(k.kH, randomz(a)); (* algorithm blur! *)
                end
                else
                begin
                        if not sig then
                        begin
                                t := randomz(a, sig);
                                encryptt[0] := power(k.kCrypt, t); (* c1 *)
                                encryptt[1] := mul(power(k.kH, t), a); (* c2 *)
                        else
                        begin
                                setModulus(k.kPhi);
                                encryptt[1] := zero;
                                while encryptt[1] = zero do
                                begin
                                        t := randomz(a, sig);
                                        encryptt[0] := power(k.kCrypt, t); (* c1 *)
                                        encryptt[1] := sub(a, mul(k.kDecrypt, encryptt[0]));
                                        encryptt[1] := mul(encryptt[1], inverse(t));
                                        if not gcd(t, k.kPhi) = one then encryptt[1] = zero; (* bad random fix *)
                                end;
                        end;
                end;
        end;

        function decryptt(a: pair, k: key, sig: boolean): value; (* private *)
        var
                t: value;
        begin
                setModulus(k.kModulus);
                if k.rsa then
                begin
                        if not sig then t := k.kCrypt else t := k.kDecrypt
                        decryptt := power(a[0], t);
                        if sig then decryptt := power(k.kCrypt, decryptt); (* match RSA to ElGamal *)
                end
                else
                begin
                        if not sig then
                                decryptt := mul(a[1], power(a[0], sub(k.kModulus, k.kDecrypt)))
                        else
                                decryptt := mul(pow(k.kH, a[0]), pow(a[0], a[1]));
                end;
        end;

        function splitValue(a: value, i: boolean, sig: boolean): value;
        var
                j, k: integer;
        begin
                splitValue := randomz(a, sig);
                if not i then k := 0 else k := (upper + 1) >> 1;
                        for j = 0 to ((upper + 1) >> 1) - 1 do
                                splitValue[j] := a[j + k];
        end;

        function encrypttt(a: value, k: key, sig: boolean): quad;
        var
                i: pair;
        begin
                i := encryptt(splitValue(a, false, sig), k, sig);
                encrypttt[0] := i[0];
                encrypttt[1] := i[1];
                i := encryptt(splitValue(a, true, sig), k, sig);
                encrypttt[2] := i[0];
                encrypttt[3] := i[1];
        end;

        function encrypt(a: value, k: key): quad; (* public *)
        begin
                encrypttt(a, k, false);
        end;

        function signHelp(a: value, b: value): value;
        begin
                (* modulus already set by decrypt *)
                a := power(k.kCrypt, a);
                signHelp := sub(a, b); (* zero on ok *)
        end;

        function decrypttt(a: quad, k: key, sig: boolean, b: value, c: value): value;
        var
                i: pair;
                j: value;
                k: integer;
        begin
                i[0] := a[0];
                i[1] := a[1];
                decrypttt := decryptt(i, k, sig); (* power if sig *)
                if sig then decrypttt := signHelp(b, decrypttt);
                i[0] := a[2];
                i[0] := a[3];
                j := decrypt(i, k, sig); (* power if sig *)
                if sig then j := signHelp(c, j);
                for k = 0 to ((upper + 1) >> 1) - 1 do
                                decrypttt[k + ((upper + 1) >> 1)] := j[k];
        end;

        function decrypt(a: quad, k: key): value; (* private *)
        begin
                decrypttt(a, k, false, zero, zero);
        end;

        function sign(a: value, k: key): quad;
        begin
                encrypttt(a, k, true);
        end;

        function check(a: quad, k: key, b: value): boolean;
        var
                i: value;
        begin
                i := decrypttt(a, k, true, splitValue(b, false, true), splitValue(b, true, true)); (* powered to k.kCrypt *)
                check := (i = zero);
        end;

        function loadPubKey(s: quad): key;
        begin
                loadPubKey.kModulus := s[0];
                loadPubKey.kCrypt := s[1];
                loadPubKey.kH := s[2];
        end;

        function savePubKey(k; key): quad;
        begin
                savePubKey[0] := k.kModulus;
                savePubKey[1] := k.kCrypt;
                savePubKey[2] := k.kH;
        end;

        function loadPrivKey(s: quad): key;
        var
                rsa: boolean;
        begin
                if s[0] = zero then rsa = true;
                if s[0] = one then rsa = false;
                loadPrivKey.rsa := rsa;
                loadPrivKey.kDecrypt := s[1];
                loadPrivKey.kPhi := s[2];
        end;

        function savePrivKey(k: key): quad;
        var
                i: value;
        begin
                if k.rsa then i := zero;
                if not k.rsa then i := one;
                savePrivKey[0] := i;
                savePrivKey[1] := k.kDecrypt;
                savePrivKey[2] := k.kPhi;
        end;
end.
