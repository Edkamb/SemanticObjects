class D (Int g)
    rule Int n()
        E v := new E();
        Int res := v.m(this.g);
        return this.g + res;
    end
end

class E()
    Int m(Int p)
        return p + p;
    end
end

main
  D a := new D(2);
  D b := new D(3);
end