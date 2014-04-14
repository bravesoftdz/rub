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
        function encrypt(a: value, k: key, sig: boolean): quad; (* public *)
        function decrypt(a: quad, k: key, sig: boolean): value; (* private *)
        function sigEqual(a: value, k: key): value; (* for checking the signature check as totient needed *)
        (* (sigEqual(a, k) = decrypt(encrypt(a, k, true), k, true)) = true  *)

        function loadPubKey(s: string): key;
        function savePubKey(k; key): string;
        function loadPrivKey(s: string): key;
        function savePrivKey(k: key): string;
        function createKey: key;
        function makePrime: value;

        (* value loading functions *)
        function load(s: string): value;
        function save(a: value): string;
        function splitLoad(s: string): array of value; (* must set modulus before this *)
        function splitSave(a: array of value): string;
        function splitEncrypt(a: array of value, k: key): array of value;
        function splitDecrypt(a: array of value, k: key): array of value;

implementation
        function randomz(a: value): value;
        var
                i: integer;
        begin
                randomize;
                for i = 0 to upper-1 do
                        random[i] := random[i] xor random(cardinal(not 0));
                random[upper] := 0; (* botch *)
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
                                t := randomz(a);
                                encryptt[0] := power(k.kCrypt, t); (* c1 *)
                                encryptt[1] := mul(power(k.kH, t), a); (* c2 *)
                        else
                        begin
                                setModulus(k.kPhi);
                                encryptt[1] := zero;
                                while encryptt[1] = zero do
                                begin
                                        t := randomz(a);
                                        encryptt[0] := power(k.kCrypt, t); (* c1 *)
                                        encryptt[1] := sub(a, mul(k.kDecrypt, encryptt[0]));
                                        encryptt[1] := mul(encryptt[1], inverse(t));
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
                        if sig then decryptt := power(k.kCrypt, decryptt);
                end
                else
                begin
                        if not sig then
                                decryptt := mul(a[1], power(a[0], sub(k.kModulus, k.kDecrypt)))
                        else
                                decryptt := mul(pow(k.kH, a[0]), pow(a[0], a[1]));
                end;
        end;

        function splitValue(a: value, i: boolean): value;
        var
                j, k: integer;
        begin
                splitValue := randomz(a);
                if not i then k := 0 else k := (upper + 1) >> 1;
                        for j = 0 to ((upper + 1) >> 1) - 1 do
                                splitValue[j] := a[j + k];
        end;

        function encrypt(a: value, k: key, sig: boolean): quad; (* public *)
        var
                i: pair;
        begin
                i := encryptt(splitValue(false), k, sig);
                encrypt[0] := i[0];
                encrypt[1] := i[1];
                i := encryptt(splitValue(true), k, sig);
                encrypt[2] := i[0];
                encrypt[3] := i[1];
        end;

        function decrypt(a: quad, k: key, sig: boolean): value; (* private *)
        var
                i: pair;
                j: value;
                k: integer;
        begin
                i[0] := a[0];
                i[1] := a[1];
                decrypt := decryptt(i, k, sig);
                i[0] := a[2];
                i[0] := a[3];
                j := decrypt(i, k, sig);
                for k = 0 to ((upper + 1) >> 1) - 1 do
                                decrypt[k + ((upper + 1) >> 1)] := j[k];
        end;

        function sigEqual(a: value, k: key) : value;
        begin
                sigEqual := power(k.kCrypt, a); (* this function exists solely to match the calculated out of an ElGamal sig check with RSA *)
        end;
end.
