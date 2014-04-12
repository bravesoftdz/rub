unit crypto
        (* this unit implements cryptography using 2 simple-ish systems known as RSA and ElGamal (cyclic group)  *)

interface
        (* all strings are base64 encoded. larger strings must be split before crypto is used. *)
        const
                upper = 255;
        type
                (* i seem to have this as little endian cardinal ordering *)
                value = array [0 .. upper] of cardinal;
                key = record
                        (* public *)
                        kModulus: value;

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
        function setModulus(value): value; (* old *)
        function negate(value): value; (* not a modulo negate, but for subtraction *)
        function sub(value, value): value;

        (* more advanced functions *)
        function modulo(value, value): value;
        function divide(value, value): value;
        function power(value, value): value;
        function gcd(value, value): value;
        function inverse(value): value;
        function greater(value, value): boolean; (* or equal to *)

implementation
        uses base64;

        var
                iModulus: value; (* two's complement modulus *)
                modulus: value;
                one: value;

        function addc(a: cardinal, b: cardinal, c: cardinal): cardinal;
        var
                tmp: QWord;
        begin
                tmp := a + b + c;
                addc := tmp >> 32;
        end;

        function addt(a: value, b: value, d: boolean): value;
        var
                i: integer;
                c: cardinal = 0;
        begin
                for i = 0 to upper do
                begin
                        addt[i] := a[i] + b[i] + c;
                        c := addc(a[i], b[i], c);
                end;
                if d and c <> 0 then addt := addt(addt, iModulus, false); (* horrid nest fix *)
        end;

        function greater(a: value, b: value): boolean;
        var
                i: integer;
        begin
                for i = upper downto 0 do
                begin
                        if a[i] < b[i] then
                        begin
                                greater := false;
                                exit;
                        end;
                        if a[i] > b[i] then
                        begin
                                greater := true;
                                exit;
                        end;
                end;
                greater := true; (* should make 0 *)
        end;

        procedure round(var a: value);
        begin
                while greater(a, modulus) do
                        a := addt(a, iModulus, false);
        end;

        function add(a: value, b: value, d: boolean): value;
        begin
                add := addt(a, b, true);
                round(add);
        end;

        function negate(a: value): value;
        var
                i: integer;
        begin
                for i = 0 to upper do
                        a[i] := not a[i];
                addt(a, one, false);
        end;

        function setModulus(a: value): value;
        var
                i: integer;
        begin
                setModulus := modulus; (* save it *)
                for i = 0 to upper do
                        one[i] := 0;
                one[0] := 1;
                modulus := a;
                iModulus := negate(a);
        end;

        function sub(a: value, b: value): value;
        begin
                sub := addt(a, negate(b), false);
                if greater(b, a) then
                begin
                        (* remap the negative *)
                        sub := addt(sub, modulus, false);
                end;
        end;

        function mul(a: value, b: value): value;
        var
                i: integer;
                f: boolean;
        begin
                mul := addt(modulus, iModulus, false); (* zero *)
                for i = 0 to (upper+1)*32-1 do
                begin
                        if a[i div 32] and (1 << (i mod 32))  then f := true; else f := false;
                        if f then mul := add(mul, b);
                        b := add(b, b); (* effective shift under modulo field *)
                end;
        end;

        function power(a: value, b: value): value;
        var
                i: integer;
                f: boolean;
        begin
                power := one;
                for i = 0 to (upper+1)*32-1 do
                begin
                        if a[i div 32] and (1 << (i mod 32))  then f := true; else f := false;
                        if f then power := mul(power, b);
                        b := mul(b, b); (* effective square under modulo field *)
                end;
        end;

        function modulo(a: value, b: value): value;
        begin

        end;

        function divide(a; value, b: value): value;
        begin

        end;

        function gcdt(a: value, b: value, c: boolean): value;
        var
                t, newt, q: value;
        begin
                t := 0;
                newt := 1;
                if greater(b, a) then
                begin
                        gcd := a;
                        a := b;
                        b := gcd; (* swap *)
                end;
                while b <> 0 do
                begin
                        gcd := modulo(a, b);
                        q := divide(a, b);
                        a := b;
                        b := gcd;
                        gcd := newt;
                        newt := sub(t, mul(q, newt));
                        t := gcd;
                end;
                gcd := a;
                (* inv or not *)

                if old_r > 1 then return "a is not invertible";
                if old_t < 0 then old_t := old_t + n;
                inverse := old_t;
        end;

        function gcd(a: value, b: value): value;
        begin
                gcdt(a, b, false);
        end;

        function inverse(a: value, b: value): value;
        begin
                gcdt(a, b, true);
        end;
end.