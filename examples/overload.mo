class <T> List(T content, List<T> next)
    Int length()
        if this.next = null then return 1;
        else Int n := this.next.length(); return n + 1;
        end
    end
    Boolean contains(T elem)
        if this.content = elem then return True; end
        if this.next = null then return False; end
        Boolean b := this.next.contains(elem);
        return b;
    end
end

class Task(String name) end

class Server(List<Task> taskList)
    Task excessive()
        Task ret := this.taskList.content;
        this.taskList := this.taskList.next;
        return ret;
    end
    Int add(Task task)
        this.taskList := new List<Task>(task, this.taskList);
        return 0;
    end
end
class Scheduler(List<Server> serverList)
    Int reschedule()
        List<Server> over := access("SELECT ?obj WHERE{?obj a :Overloaded }");
        //breakpoint;
        List<Task> tasks := this.collectExcessiveTasks(over);
        //breakpoint;
        tasks := this.rescheduleTasks(tasks, over);
        //breakpoint;
        while tasks <> null do
            List<Task> l := new List<Task>(tasks.content, null);
            Server n := new Server(l);
            this.serverList := new List(n, this.serverList);
            tasks := tasks.next;
        end
        return 0;
    end

    List<Task> collectExcessiveTasks(List<Server> overloaded)
       List<Server> plats := this.serverList;
       List<Task> exc := null;
       while plats <> null do
            Boolean b := overloaded.contains(plats.content);
            //breakpoint;
            if b then
                Task localExc := plats.content.excessive();
                exc := new List(localExc, exc);
            end
            plats := plats.next;
       end
       return exc;
    end

    List<Task> rescheduleTasks(List<Task> tasks, List<Server> overloaded)
       List<Server> plats := this.serverList;
       while plats <> null do
            Boolean b := overloaded.contains(plats.content);
            if b then
                skip;
            else
                plats.content.add(tasks.content);
                tasks := tasks.next;
            end
            plats := plats.next;
            if tasks = null then return null; end
       end
       return tasks;
    end
end

main
    Task task1 := new Task("t1");
    Task task2 := new Task("t2");
    Task task3 := new Task("t3");
    Task task4 := new Task("t4");
    Task task5 := new Task("t5");
    Task task6 := new Task("t6");

    List<Task> l1 := new List(task1, null);
    List<Task> l2 := new List(task2, null);
    List<Task> l3 := new List(task3, l2);
    List<Task> l4 := new List(task4, null);
    List<Task> l5 := new List(task5, l4);
    List<Task> l6 := new List(task6, l5);

    Server dummy := new Server(null);
    Server server1 := new Server(l1);
    Server server2 := new Server(l3);
    Server server3 := new Server(l6);
    List<Server> sl1 := new List(server3, null);
    List<Server> sl2 := new List(server2, sl1);
    List<Server> sl3 := new List(server1, sl2);

    Scheduler sch := new Scheduler(sl3);
    breakpoint;
    sch.reschedule();
end
