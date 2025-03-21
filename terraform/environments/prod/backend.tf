terraform { 
  cloud { 
    
    organization = "voltaflow" 

    workspaces { 
      name = "Main" 
    } 
  } 
}