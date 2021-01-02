//NOTE: this was written before we added booleans

class GeoElement (Int sealing)

end

class Dummy()

end

class LeftHydrocarbonMigration (GeoUnit gu)
    Int migrate()
        GeoUnit started := this.gu;
        Int b := 1;
        while b = 1 do
            b := this.gu.migrate();
        end
        Touch left := this.gu.left;
        if left <> null then
            left.migrateLeft(this);
        end
        if started <> this.gu then
            this.migrate();
        end
        return 0;
    end
    LeftHydrocarbonMigration copy(Boolean param)
        LeftHydrocarbonMigration c := new LeftHydrocarbonMigration(param);
        return c;
    end
end

class <T> List(T content, List<T> next)

    Int append(List<T> last)
        if this.next = null then
            this.next := last;
        else
            this.next.append(last);
        end
        return 0;
    end

    T get(Int i)
        T res := this.content;
        if i >= 1 then
            res := this.next.get(i-1);
        end
        return res;
    end

    Int contains(T element)
        if this.content = element then
            return 1;
        else
            if this.next = null then
                return 0;
            else
                Int res := this.next.contains(element);
                return res;
            end
        end
    end
end

class GeoManager (List<GeoUnit> list)
    GeoUnit createNew(Boolean seal)
        GeoUnit tmp := new GeoUnit(seal, null, null, null, null, null);
        this.list := new List(tmp, this.list);
        return tmp;
    end

    Int connectLR(GeoUnit g1, GeoUnit g2)
        Touch cn1 := new Touch(0, g1, g2);
        g1.right := cn1;
        g2.left := cn1;
        return 0;
    end


    Int connectTB(GeoUnit g1, GeoUnit g2)
        Touch cn1 := new Touch(0, g1, g2);
        g1.bottom := cn1;
        g2.top := cn1;
        return 0;
    end

    Int startEarthquake(Int sealing, GeoUnit gu)
        Int known := this.list.contains(gu);
        if known = 1 then
            while gu.top <> null do
                gu := gu.top.s1;
            end
            Fault fault := new Fault(sealing, null, null);
            gu.earthquake(fault);
            return 0;
        else return 0; end
    end
end



class GeoUnit extends GeoElement (Touch top, Touch left, Touch right, Touch bottom, LeftHydrocarbonMigration migration)
    Int earthquake(Fault fault)
        if this.right <> null then
            fault.replaces(this.right);
            if this.bottom <> null then
                this.bottom.s2.earthquake(fault);
            end
        end
        return 0;
    end

    Int migrate()
        if this.top <> null then
            if this.top.s1.sealing <> 1 then
                GeoElement old := this.migration.gu;
                this.top.s1.migration := this.migration;
                this.migration.gu := this.top.s1;
                old.migration := null;
                return 1;
            end
        end
        return 0;
    end

    GeoUnit getTopNonSealing()
        if this.sealing <> 1 then
            return this;
        else
            if this.top <> null then
                GeoElement target := this.top.s1;
                GeoUnit res := target.getTopNonSealing();
                return res;
            else return this; end
        end
    end
end

class Touch extends GeoElement (GeoElement s1, GeoElement s2)
    Int migrateLeft(LeftHydrocarbonMigration mig)
        if this.s1.sealing <> 1 then
            if this.s1.migration = null then
                GeoElement old := mig.gu;
                this.s1.migration := mig;
                mig.gu := this.s1;
                old.migration := null;
                return 1;
            end
        end
        return 0;
    end
end

class Fault extends GeoElement (List<GeoElement> s1, List<GeoElement> s2)
    Int replaces(Touch touch)
        touch.s1.right := this;
        touch.s2.left  := this;
        this.s1 := new List(touch.s1, this.s1);
        this.s2 := new List(touch.s2, this.s2);
        return 0;
    end

    Int migrateLeft(LeftHydrocarbonMigration mig)
        if this.sealing <> 1 then
            if this.s1 <> null then
                GeoElement currentLeft := this.s1;
                GeoElement currentRight := this.s2;
                while currentRight.content <> mig.gu do
                    currentLeft := currentLeft.next;
                    currentRight := currentRight.next;
                end
                GeoUnit finalLeft := currentLeft.content.getTopNonSealing();
                if finalLeft.sealing <> 1 then
                    if finalLeft.migration = null then
                        GeoUnit old := mig.gu;
                        finalLeft.migration := mig;
                        mig.gu := finalLeft;
                        old.migration := null;
                        return 1;
                   end
                end
            end
        end
        return 0;
    end
end


main
    GeoUnit gu11 := new GeoUnit(1, null, null, null, null, null);
    List<GeoUnit> initList := new List<GeoUnit>(gu11, null);
    GeoManager manager := new GeoManager(initList);



    gu12 := manager.createNew(1);
    gu13 := manager.createNew(1);
    gu14 := manager.createNew(1);
    gu15 := manager.createNew(1);
    manager.connectLR(gu11, gu12);
    manager.connectLR(gu12, gu13);
    manager.connectLR(gu13, gu14);
    manager.connectLR(gu14, gu15);

    print("1:-XX|XX-");

    gu21 := manager.createNew(1);
    gu22 := manager.createNew(0);
    gu23 := manager.createNew(1);
    gu24 := manager.createNew(0);
    gu25 := manager.createNew(1);
    manager.connectTB(gu11, gu21);
    manager.connectTB(gu12, gu22);
    manager.connectTB(gu13, gu23);
    manager.connectTB(gu14, gu24);
    manager.connectTB(gu15, gu25);
    manager.connectLR(gu21, gu22);
    manager.connectLR(gu22, gu23);
    manager.connectLR(gu23, gu24);
    manager.connectLR(gu24, gu25);

    print("2:X X| X-");

    gu31 := manager.createNew(1);
    gu32 := manager.createNew(0);
    gu33 := manager.createNew(0);
    gu34 := manager.createNew(1);
    gu35 := manager.createNew(1);
    manager.connectTB(gu21, gu31);
    manager.connectTB(gu22, gu32);
    manager.connectTB(gu23, gu33);
    manager.connectTB(gu24, gu34);
    manager.connectTB(gu25, gu35);
    manager.connectLR(gu31, gu32);
    manager.connectLR(gu32, gu33);
    manager.connectLR(gu33, gu34);
    manager.connectLR(gu34, gu35);

    print("3:X  |XX-");

    gu41 := manager.createNew(1);
    gu42 := manager.createNew(1);
    gu43 := manager.createNew(1);
    gu44 := manager.createNew(1);
    gu45 := manager.createNew(1);
    gu46 := manager.createNew(1);

    manager.connectTB(gu31, gu41);
    manager.connectTB(gu32, gu42);
    manager.connectTB(gu33, gu43);
    manager.connectTB(gu34, gu44);
    manager.connectTB(gu35, gu45);

    manager.connectLR(gu41, gu42);
    manager.connectLR(gu42, gu43);
    manager.connectLR(gu43, gu44);
    manager.connectLR(gu44, gu45);
    manager.connectLR(gu45, gu46);

    print("4:XXX|XXX");

    gu53 := manager.createNew(1);
    gu54 := manager.createNew(0);
    gu55 := manager.createNew(0);
    gu56 := manager.createNew(1);
    manager.connectTB(gu43, gu53);
    manager.connectTB(gu44, gu54);
    manager.connectTB(gu45, gu55);
    manager.connectTB(gu46, gu56);
    manager.connectLR(gu53, gu54);
    manager.connectLR(gu54, gu55);
    manager.connectLR(gu55, gu56);

    print("5:--X|  X");

    gu63 := manager.createNew(1);
    gu64 := manager.createNew(1);
    gu65 := manager.createNew(1);
    gu66 := manager.createNew(1);
    manager.connectTB(gu53, gu63);
    manager.connectTB(gu54, gu64);
    manager.connectTB(gu55, gu65);
    manager.connectTB(gu56, gu66);
    manager.connectLR(gu63, gu64);
    manager.connectLR(gu64, gu65);
    manager.connectLR(gu65, gu66);

    print("6:--X|XXX");


    manager.startEarthquake(0, gu63);

    LeftHydrocarbonMigration mig := new LeftHydrocarbonMigration(gu55);
    gu55.migration := mig;

    //instead of mig.migrate(); we use ontology-based reflexion
    List<LeftHydrocarbonMigration> all := access("SELECT ?obj WHERE {?obj smol:instanceOf prog:LeftHydrocarbonMigration }");
    all.content.migrate();
    List<Object> nulls := access("SELECT ?obj WHERE { ?obj a :HasAnyNullNext }");
    print(nulls);
end
