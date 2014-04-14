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

        uses base64, modulo;
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

        (* key and general encryption fiunctions *)
        function encrypt(a: value, k: key): pair; (* public *)
        function decrypt(a: pair, k: key): value; (* private *)
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
                for i = 0 to upper do
                        random[i] := random[i] xor random(cardinal(not 0));
        end;

        function makePrime: value;
        begin

        end;

        function createKey: key;
        begin

        end;

        function encrypt(a: value, k: key): pair; (* public *)
        begin
                setModulus(k.kModulus);
                if k.rsa then
                begin
                        encrypt[0] := power(a, k.kCrypt);
                        encrypt[1] := power(k.kH, randomz(a)); (* algorithm blur! *)
                end
                else
                begin
                        var y: value;
                        y := randomz(a);
                        encrypt[0] := power(k.kCrypt, y); (* c1 *)
                        encrypt[1] := mul(power(k.kH, y), a); (* c2 *)
                end;
        end;

        function decrypt(a: pair, k: key): value; (* private *)
        begin
                setModulus(k.kModulus);
                if k.rsa then
                begin
                        decrypt := power(a[0], k.kDecrypt);
                end
                else
                begin
                        decrypt := mul(a[1], power(a[0], sub(k.kModulus, k.kDecrypt)));
                end;
        end;
end.
