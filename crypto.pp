unit crypto
        (* this unit implements cryptography using 2 simple-ish systems known as RSA and ElGamal (cyclic group)  *)
        uses base64, modulo;

interface
        (* all strings are base64 encoded. larger strings must be split before crypto is used. *)
        type
                (* i seem to have this as little endian cardinal ordering *)
                key = record
                        (* public *)
                        kModulus: value; (* q *)
                        kCrypt: value; (* g *)
                        kH: value; (* ElGamal g^x mod q => rsa public key signed *)

                        (* private *)
                        rsa: boolean; (* true? *)
                        kDecrypt: value; (* x *) (* in rsa, uses lcm((p-1)(q-1)) method *)

                end;

        (* key and general encryption fiunctions *)
        function encrypt(value, key): value; (* public *)
        function decrypt(value, key): value; (* private *)
        function loadPubKey(string): key;
        function savePubKey(key): string;
        function loadPrivKey(string): key;
        function savePrivKey(key): string;
        function createKey(): key;

        (* value loading functions *)
        function load(string): value;
        function save(string): value;
        function splitLoad(string): array of value; (* must set modulus before this *)
        function splitSave(array of value): string;
        function splitEncrypt(array of value, key): array of value;
        function splitDecrypt(array of value, key): array of value;

implementation

end.