import MyMacro

let toto = ""

#AutoCancellableTask { [toto] in
  print("Test tutu1234")
}

@ManagingTask
struct TestE {

}

#CancelAllTasks
