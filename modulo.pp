unit modulo
        (* this unit implements modulo arithmetic for RSA and ElGamal (cyclic group)  *)

interface
        const
                upper = 255;
        type
                (* i seem to have this as little endian cardinal ordering *)
                value = array [0 .. upper] of cardinal;
                pair = array [0 .. 1] of value;

        (* arithmetic functions *)
        function add(a: value, b: value): value;
        function mul(a: value, b: value): value;
        function setModulus(a: value): value; (* old *)
        function negate(a: value): value; (* not a modulo negate, but for subtraction *)
        function sub(a: value, b: value): value;

        (* more advanced functions *)
        function divide(a: value, b: value): pair; (* 0 = quotient, 1 = remainder *)
        function power(a: value, b: value): value;
        function gcd(a: value, b: value): value;
        function inverse(a: value): value;
        function greater(a: value, b: value): boolean; (* or equal to *)

implementation
        var
                iModulus: value; (* two's complement modulus *)
                modulus: value;
                zero: value;
                one: value;
                nogo: boolean;

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
                if greater(modulus, one) then (* zero is no modulus *)
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
                        zero[i] := 0;
                one := zero;
                one[0] := 1;
                modulus := a;
                iModulus := negate(a);
        end;

        function sub(a: value, b: value): value;
        begin
                sub := addt(a, negate(b), false);
                nogo := false;
                if greater(b, a) then
                begin
                        (* remap the negative *)
                        sub := addt(sub, modulus, false);
                        nogo := true;
                end;
        end;

        function mul(a: value, b: value): value;
        var
                i: integer;
                f: boolean;
        begin
                mul := zero;
                for i = 0 to (upper+1)*32-1 do
                begin
                        if (a[i div 32] and (1 << (i mod 32))) <> 0 then f := true; else f := false;
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
                        if (a[i div 32] and (1 << (i mod 32))) <> 0 then f := true; else f := false;
                        if f then power := mul(power, b);
                        b := mul(b, b); (* effective square under modulo field *)
                end;
        end;

        function divide(a; value, b: value): pair;
        var
                i: integer;
                f: boolean;
                r, tmp: value;
        begin
                r := zero;
                tmp := setModulus(zero);
                for i = 0 to (upper+1)*32-1 do
                begin
                        r := add(r, r);
                        if (a[upper] and (1 << 31)) <> 0 then
                                r := add(r, one);
                        a := add(a, a); (* shift *)
                        r := sub(r, b);
                        if nogo then
                                r := add(r, b); (* add back *)
                        else
                                a := add(a, one); (* divides *)
                end;
                pair[0] := a;
                pair[1] := r;
                temp := setModulus(tmp);
        end;

        function gcdt(a: value, b: value, c: boolean): value;
        var
                t, newt, q, temp: value;
                p: pair;
                s: boolean = false; (* positive *)
                news: boolean = false;
        begin
                t := zero;
                newt := one;
                temp := setModulus(zero);
                if greater(b, a) then
                begin
                        gcdt := a;
                        a := b;
                        b := gcdt; (* swap *)
                end;
                while b <> zero do
                begin
                        p := divide(a, b);
                        q := p[0];
                        gcdt := p[1];
                        a := b;
                        b := gcdt;
                        if c then
                        begin
                                gcdt := newt;
                                if news then
                                begin
                                        newt := negate(newt);
                                        t := negate(t);
                                end;
                                s := news;
                                newt := sub(t, mul(q, newt));
                                news := nogo;
                                if s then
                                begin
                                        newt := negate(newt);
                                        news := not news;
                                end;
                                t := gcdt;
                        end;
                end;
                if not c then gcdt := a;
                (* inv or not *)
                if c then gcdt := t;
                if s then gcdt := add(gcdt, temp);
                if (greater(sub(a, one), one) and c) then gcdt := zero; (* no inverse *)
                temp := setModulus(temp);
        end;

        function gcd(a: value, b: value): value;
        begin
                gcdt(a, b, false);
        end;

        function inverse(a: value): value;
        begin
                gcdt(a, modulus, true);
        end;
end.
