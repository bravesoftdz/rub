unit crypto
(* this unit implements cryptography using 2 simple-ish systems known as RSA and ElGamal (cyclic group)  *)
interface
        (* all strings are base64 encoded. larger strings must be split before crypto is used. *)
        type
                value = array [0 .. 255] of cardinal;
                key = record
                        (* public *)
                        modulus: value;

                        (* private *)

                end;

        (* key and general encryption fiunctions *)
        function encrypt(value, key): value; (* public *)
        function decrypt(value, key): value; (* private *)
        function loadPubKey(string): key;
        function savePubKey(key0: string;
        function loadPrivKey(string): key;
        function savePrivKey(key): string;
        function mergePubPriv(key, key): key;

        (* value loading functions *)
        function load(string): value;
        function save(string): value;
        function splitLoad(string): array of value; (* must set modulus before this *)
        function splitSave(array of value): string;
        function splitEncrypt(array of value, key): array of value;
        function splitDecrypt(array of value, key): array of value;

        (* arithmetic functions *)
        function add(value, value): value;
        function mul(value, value): value;
        function sqr(value): value;
        function setModulus(value): value; (* old (using +1 offset) *)
        function negate(value): value;

        (* more advanced functions *)
        function power(value, value): value;
        function divide(value, value): value;
        function gcd(value, value): value;
        function inverse(value): value;
implementation
        uses base64;

end.
