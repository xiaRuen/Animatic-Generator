// 1. parse by '/n'
// 2. for each parsed line, parse by ' '
ArrayList<ArrayList<String>> loadInstructions(String path) {
  String strs[] = loadStrings(path);

  // if file not found
  if (strs == null) {
    return null;
  }

  ArrayList<ArrayList<String>> rVal = new ArrayList<ArrayList<String>>();
  
  for (int i = 0; i < strs.length; i++) {
    rVal.add(new ArrayList(Arrays.asList(strs[i].split(" "))));
  }

  return rVal;
}

void saveInstructions(ArrayList<ArrayList<String>> instructions){
    String str[] = new String[instructions.size()];
    for(int i = 0; i < str.length; i++){
      str[i] = String.join(" ", instructions.get(i));
    }
    saveStrings(instructionFilePath, str);

}


SoundFile loadMusic(String path){
  if(!pathExist(path)){
    return null;
  } else {
    return new SoundFile(app, path);
  }
}


boolean pathExist(String path){
  return Files.exists(Paths.get(path));
}
