/* Fork from Diana Lange on OpenProcessing http://www.openprocessing.org/user/5969 */
/* Fix some bugs for using in Processing 3.x & add saveFrame by LuZhouheng  http://github.com/luzhouheng */

// # -*- coding: utf-8 -*-
// # @Author: Diana Lange
// # @Date:   2013-01-??
// # @Last modified by:   LuZhouheng
// # @Last Modified time: 2016-03-22 19:53:07

// How to use this program for generate your personnal Avatar Image, Please follow this workflow
// * Put your personal image in the 'data' file
// * change the 'inputPath' name, and run this program
// * press number keys : 0 ~ 1 for change points number => 500 ~ 25000
// * press 'M' key for change points' linking mode & press 'N' key for refresh image
// * if you want to save the images you created, just press 'S' key to save it, have fun~ :)

//Must import this java library so that can build succesefully
import java.util.Calendar;  //fix this bug from https://forum.processing.org/one/topic/error-when-trying-to-run-sketch-cannot-find-a-class-or-type-named-calendar.html

final String inputPath = "TaobaoAvatar.jpg";
int particelNum = 20000, speed = 200;
boolean showImage = false;

PImage img;
PImage input, over;
PFont font;
ArrayList <PVector> pc;
ArrayList <Line> lines;

int mode = 0, connectionMode = 0;

void setup ()
{ 
  img = loadImage("TaobaoAvatar.jpg");
  surface.setSize (img.width, img.height);
  smooth();

  frameRate (25);
  font = createFont ("Arial", 14);

  input = loadImage (inputPath);
  if (input.width != width || input.height != height) input.resize (width, height);

  initPointCloud();

  over = createImage (1, 1, RGB);
  for (int i = 0; i < over.pixels.length; i++) over.pixels [i] = color (230);
  over.updatePixels();
}

void draw ()
{
  background (255);

  strokeWeight (0.5);
  noFill();
  stroke (120, 255);
  PVector pos;
  for (int i = 0; i < pc.size(); i++) 
  {
    pos = pc.get (i);
    point (pos.x, pos.y);
  }

  strokeWeight (0.25);
  stroke (0, 150);
  for (int i = 0; i < lines.size(); i++) 
  {
    lines.get (i).strokeSytle();
    if (mode == 1) lines.get (i).draw();
    if (mode == 0) lines.get (i).drawSmooth ();
  }

  if (pc.size() > 0)
  {
    fill (120);
    noStroke();
    String txt = "Processing";
    if (frameCount % 3 == 0) txt+=".  ";
    else if (frameCount %3 == 1) txt+=".. ";
    else txt+="...";
    txt+=" [" + nf ((float) (particelNum-pc.size()) / (float) particelNum * 100.0, 0, 2) + "%]";
    text (txt, 20, height-15 );
  }

  for (int i = 0; i < speed; i++) creatConnection(connectionMode);

  blend (over, 0, 0, width, height, 0, 0, width, height, MULTIPLY);

  if (showImage) image (input, 10, 10, input.width/4, input.height/4);
}

void initPointCloud()
{
  pc = new ArrayList ();
  lines = new ArrayList();

  PVector [] targets = findTargets (particelNum, input);
  for (int i = 0; i < targets.length; i++) pc.add (targets [i]);
}

void creatConnection (int cMode)
{
  if (lines.size() == 0 && pc.size() > 2)
  {
    PVector start, end;
    int startindex = (int) random (pc.size());
    start = pc.get (startindex);
    pc.remove (startindex);
    int endindex = getClosestIndex (start, pc);
    end = pc.get (endindex);
    pc.remove (endindex);
    lines.add (new Line (start, end));
    lines.get (lines.size()-1).setStrokeWeightAndColor(input.pixels, input.width, input.height);
  }
  else {
    if (pc.size() > 0)
    {
      PVector start = lines.get (lines.size()-1).end, end;
      int index = cMode == 0 ? getClosestIndex (start, 7, pc) : getClosestIndex (start, pc);
      end = pc.get (index);
      pc.remove (index);
      lines.add (new Line (start, end));
      lines.get (lines.size()-1).setStrokeWeightAndColor(input.pixels, input.width, input.height);
    }
  }
}

int getClosestIndex (PVector start, ArrayList <PVector> lookup)
{
  float closestDist = width*height;
  int closestIndex = 0;

  float dis = 0;
  for (int i = 0; i < lookup.size(); i++)
  {
    dis = PVector.dist (start, lookup.get(i));
    if (dis < closestDist)
    {
      closestDist = dis;
      closestIndex = i;
    }
  }
  return closestIndex;
}

int getClosestIndex (PVector start, int n, ArrayList <PVector> lookup)
{
  float [] closestDist = new float [n];
  int [] closestIndex = new int [n];

  for (int i = 0; i < n; i++) 
  {
    closestDist [i] = width*height;
    closestIndex [i] = 0;
  }

  float dis = 0;
  float disMin = width*height, disMax = disMin*2;

  for (int i = 0; i < lookup.size(); i++)
  {
    dis = PVector.dist (start, lookup.get(i));
    if (dis < disMin )
    {
      disMin = dis;
      closestDist[0] = dis;
      closestIndex [0] = i;
    }
    else if (dis > disMin && dis < disMax)
    {
      int index = i;
      for (int j = 0; j < n-1; j++)
      {
        if (closestDist[j] < dis &&  closestDist[j+1] > dis)
        {

          index=j+1;
          //println (index);
          break;
        }
      }

      for (int j = n-1; j > 0; j--)
      {
        if (j == index)
        {
          closestDist [j] = dis;
          closestIndex [j] = i;
          break;
        }
        else 
        {
          if (j > 1)
          {
            closestIndex [j] = closestIndex [j-1];
            closestDist[j] = closestDist [j-1];
          }
        }
      }
      //println(closestDist);
      disMax = closestDist[n-1];
    }
  }

  int index = closestIndex [(int) random (n)];

  return index;
}


void mousePressed ()
{
  if (mouseButton == LEFT) initPointCloud();
}


void keyPressed ()
{
  if (keyCode == '1') 
  {
    particelNum = 500;
    initPointCloud();
  }
  if (keyCode == '2') 
  {
    particelNum = 1000;
    initPointCloud();
  }
  if (keyCode == '3') 
  {
    particelNum = 2000;
    initPointCloud();
  }
  if (keyCode == '4') 
  {
    particelNum = 3000;
    initPointCloud();
  }
  if (keyCode == '5') 
  {
    particelNum = 4000;
    initPointCloud();
  }
  if (keyCode == '6') 
  {
    particelNum = 5000;
    initPointCloud();
  }
  if (keyCode == '7') 
  {
    particelNum = 8000;
    initPointCloud();
  }
  if (keyCode == '8') 
  {
    particelNum = 10000;
    initPointCloud();
  }
  if (keyCode == '9') 
  {
    particelNum = 15000;
    initPointCloud();
  }
  if (keyCode == '0') 
  {
    particelNum = 25000;
    initPointCloud();
  }
  if (keyCode == 'I') showImage = !showImage;

  if (keyCode == 'M')
  {
    mode++;
    if (mode > 1) mode = 0;
  }
  if (keyCode == 'N')
  {
    connectionMode++;
    if (connectionMode > 1) connectionMode = 0;
    initPointCloud();
  }
  if(keyCode == 'S')
  {
    saveFrame("####.png");
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}