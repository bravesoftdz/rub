unit sorter;
        (* a simple quick sort routine for sorting an array of integers *)
interface
        const
                qupper = 2047; (* quad sized rub *)
        type
                compare = function(i, j: integer): boolean;
                lquad = array [0 .. qupper] of integer;

        function sort(a: lquad; w: compare): lquad;
        function lessThan(i, j: integer): boolean;
implementation

        var
                index: lquad;

        function lessThan(i, j: integer): boolean;
        begin
                lessthan := index[i]<index[j];
        end;

        procedure swap(i, j: integer);
        var
                t: integer;
        begin
                t := index[i];
                index[i] := index[j];
                index[j] := t;
        end;

        function partition(left, right, pivotIndex: integer): integer;
        var
                storeIndex, i: integer;
        begin
                swap(pivotIndex, right);
                storeIndex := left;
                for i := left to right - 1 do
                        if lessThan(i, pivotIndex) then
                        begin
                                swap(i, storeIndex);
                                storeIndex := storeIndex + 1;
                        end;
                swap(storeIndex, right);
                partition := storeIndex;
        end;

        procedure qsort(left, right: integer);
        var
                pivotIndex, pivotNewIndex: integer;
        begin
                if right > left then
                begin
                        pivotIndex := left + (right - left) div 2;
                        pivotNewIndex := partition(left, right, pivotIndex);
                        qsort(left, pivotNewIndex - 1);
                        qsort(pivotNewIndex + 1, right);
                end;
        end;

        function sort(a: lquad; w: compare): lquad;
        begin
                index := a;
                qsort(0, length(a));
                sort := index;
        end;
end.
