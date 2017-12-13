//  neurofun 2017
//
//  adapted from Kamal Mostafa's hershey-fonts package
//  http://www.whence.com/hershey-fonts/
//
//
/*
    Converts hershey font files(.jhf) to a coordinate array that describes each character in a way suitable for a C program.
    The characters range from space (32) to (127), that is, 96 characters.
    For each character the first item is the number of vertices needed to describe the character.
    The second item is the horizontal spacing of the character, the distance from the bottom left to the bottom right.
    The subsequent items are vertex pairs. A vertex of (-1,-1) indicates a pen up operation.
*/
//  See <http://paulbourke.net/dataformats/hershey/> for an example.


PrintWriter output;
String input_file = null;
String output_file;
String line = null;

int x;
int y;
int nverts_max = 0;
int glyph_count = 0;

final int MAX_NUMBER_OF_VERTEX = 155;  //japanese font uses up to 155 vertices for a glyph
class h_vertex{
  int x, y;
  h_vertex(){
    x=-1;
    y=-1;
  }
}

class h_glyph{
  int nverts;
  int hor_spacing;
  h_vertex[] vertex;
}

h_glyph[]  glyph;

//dark on light
final int bgc = 200;
final int fgc = 0;

//light on dark
//final int bgc = 0;
//final int fgc = 255;

final int scale = 2;  //set resolution manualy in setup()

//////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  //size(1200, 900);  //scale = 3
  size(800, 600);  //scale = 2
  background(bgc);

  //init arrays
  glyph = new h_glyph[1600];  //hersey font has 1597 entries
  for (int i = 0; i < glyph.length; i++) {
    glyph[i] = new h_glyph(); 
    glyph[i].vertex = new h_vertex[MAX_NUMBER_OF_VERTEX];
    for (int j = 0; j < glyph[i].vertex.length; j++) {
      glyph[i].vertex[j] = new h_vertex(); 
    }
  }

  selectInput("Select a hershey font file", "fileSelected");
  noLoop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////
void draw(){
  if(input_file != null){
    hershey_jhf_font_load();
    hershey_font_output();
    println("output "+output_file);
    println("done");
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
void fileSelected(File selection) {
  if (selection == null) {
    println("exit");
    exit();
  } else {
    println("converting " + selection.getAbsolutePath());
    input_file = selection.getAbsolutePath();
    redraw();
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//output converted data to file
void hershey_font_output()
{
  String path[] = split(input_file, ".");
  String filename[] = split(path[0], "/");
  String headername = "_"+filename[filename.length-1]+"_h";
  surface.setTitle(filename[filename.length-1]);
  output_file = path[0] + ".h";
  output = createWriter(output_file);
  output.println("#ifndef "+headername);
  output.println("#define "+headername);
  output.println("");
  if(nverts_max<128){
    output.println("const int8_t simplex["+glyph_count+"]["+(nverts_max*2+2)+"] = {");
  }else{
    output.println("const int16_t simplex["+glyph_count+"]["+(nverts_max*2+2)+"] = {");
  }

  for(int i = 0; i < glyph_count; i++){
    //output vertex array to file
    output.print("{"+glyph[i].nverts+", "+glyph[i].hor_spacing+",");
    output.print(" /* Ascii "+(i+32)+" */");
    output.println("");
    for (int j = 0; j < nverts_max; j++) {
      if(j < nverts_max-1){
        output.print(glyph[i].vertex[j].x+", "+glyph[i].vertex[j].y+", ");
      }else{
        output.println(glyph[i].vertex[j].x+", "+glyph[i].vertex[j].y+"},");
      }
    }
  }

  output.println("};");
  output.println("#endif");
  output.println("//number of glyphs "+glyph_count);
  output.println("//max number of vertices "+nverts_max);
  output.close();
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//read font file line by line
void hershey_jhf_font_load()
{
  BufferedReader reader = createReader(input_file);
  try {
    while ((line = reader.readLine()) != null) {
      int r;
      r = hershey_jhf_load_glyph();
      glyph_count++;
    }
    reader.close();
    //output debug info to console
    println("number of glyphs "+glyph_count);
    println("max number of vertices in a glyph "+nverts_max);
  } catch (IOException e) {  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// Convert "Hershey-values" (offset by ASCII 'R') to integers
int hershey_val(char c) { return (c - 'R'); }

//////////////////////////////////////////////////////////////////////////////////////////////////
//convert and draw glyph
int hershey_jhf_load_glyph()
{
  int glyphnum, nverts;
  int leftpos, rightpos;

  int len = line.length();
  if (line.charAt(len-1) == '\n' ) {
    len--;
  }
  if ( len < 10 ) {
    println("line length "+len+" is too short");
    return 0;
  }

  String temp = line.substring(0,5);
  //println(temp);
  glyphnum = int(trim(temp));
  temp = line.substring(5,8);
  //println(temp);
  nverts = int(trim(temp));
  if(glyphnum == 0 || nverts == 0){
    println("invalid hershey font file\nexit");
    exit();
  }

  len -= 8;

  if ( nverts*2 != len ) {
    println("expected "+nverts*2+" (not "+len+") coord bytes for nverts="+nverts);
    return 0;
  }

  leftpos = hershey_val(line.charAt(8));
  rightpos = hershey_val(line.charAt(9));
  int hor_spacing = rightpos - leftpos;
  if ( hor_spacing < 0 ) {
    println("bogus leftpos "+leftpos+" > rightpos "+rightpos);
    return 0;
  }
  // skip over the (leftpos,rightpos) pair
  nverts = nverts - 1;
  glyph[glyph_count].nverts = nverts;
  glyph[glyph_count].hor_spacing = hor_spacing;
  int i;
  int j = 0;
  int npaths = 0;
  // split out the seperate line paths
  for ( i=1; i<=nverts; i++ ) {
    // pen up
    if ( i==nverts || (line.charAt(10+i*2)==' ' && line.charAt(11+i*2)=='R') ) {
        int npathverts = i - j;
        // Copy the vertices into glyph->vertex with y-invert and offsets to
        // place the glyph origin at its lower left baseline corner with
        // standard Cartesian coordinates.
        int xoffset = -leftpos;  // shift left edge to 0
        int yoffset = 16 - 7;  // (height - baseline) FIXME? hardcoded
        int k;
        stroke(fgc);
        noFill();
        beginShape();
        for ( k=0; k<npathverts; k++ ) {
          x =  xoffset + hershey_val(line.charAt(10+(k+j)*2));
          //y =  yoffset + hershey_val(line.charAt(11+(k+j)*2));  //for positive y axis down
          y =  yoffset - hershey_val(line.charAt(11+(k+j)*2));  //for positive y axis up
          glyph[glyph_count].vertex[k+j].x = x;
          glyph[glyph_count].vertex[k+j].y = y;
          //output to screen
          vertex(x*scale+(glyph_count%12)*scale*33+scale*4, (yoffset-y)*scale+(glyph_count/12)*scale*33+scale*25);
        }
        endShape();
        npaths++;
        j = i + 1;
    }
  }
  //output debug info to console
  if(nverts > nverts_max) nverts_max = nverts;
  println("glyph id "+glyphnum+"\tvertices "+nverts+"\tpaths "+npaths);
  return 1;
}