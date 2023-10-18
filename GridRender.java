import java.util.ArrayList;
/**
 * contains the tools for rendering a grid 
 *
 * right now this handles width much better than height 
 * in the future this would be a great thing to improve apon and re-use for 
 * other assignments, but this works for the time bieng
 * */
class GridRender<T> {

	public static int getMaxWidth(String s) {
		int width = -1;
		for (String word : s.split("\n")) {
			if (word.length() > width) {
				width = word.length();
			}
		}
		return width;
	}

	public static int getMaxHeight(String s) {
		int height = -1;
		return s.split("\n").length;
	}

	/**
	 *	padds out a string until it is the given width
	 * */
	public static String ensureWidth(String s, int width,String padding_value) {

		while (s.length() < width) {
			s = s + padding_value;
		}

		return s;
	}
	//draws a grid of the given information
	public static <T> String renderGrid(ArrayList<ArrayList<T>> table,String title) {
		int max_height = -1;
		int max_width = -1;
		
		for (ArrayList<T> row : table) {
			for (T cell : row) {
				int height = getMaxHeight(cell.toString());
				int width = getMaxWidth(cell.toString());

				if (height > max_height)
					max_height = height;
				if (width > max_width)
					max_width = width;

			}
		}



		int seperator_size =(1+max_width)*table.get(0).size()+1;
		String seperator = "";
		for (int i = 0; i < seperator_size;i++) {
			if (i % (1+max_width) == 0)
				seperator += "+";
			else 
				seperator += "-";
		}


		//seperator = "+" + seperator + "+\n"; 
		seperator += "\n";
		String ret_val = "";
		

		for (ArrayList<T> row : table) {
			String line = "|";
			for (T cell : row) {
				line += ensureWidth(cell.toString(),max_width," ") + "|";
			}
			ret_val += seperator+line + "\n";
		}
		ret_val +=  seperator + "\n";

		//could I center the title?, yes :)
		//will I center the title?, no :p
		ret_val = title + "\n" + ret_val; 


		return ret_val;
	}



	public static void main(String [] args)  {

		ArrayList<ArrayList<String>> table = new ArrayList<ArrayList<String>>();

		for (int i = 0; i < 5; i++)
		{
			ArrayList<String> row = new ArrayList<>();
			
			for (int j = 0; j < 5; j++) {
				String val = Integer.toString(i) + "," + Integer.toString(j) + " AHHH";
				row.add(val);
			}

			table.add(row);
		}

		System.out.println(renderGrid(table,"test"));


	}
 

}
