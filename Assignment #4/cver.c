#include <stdio.h>

#define FALSE  0
#define TRUE   1

struct point {
		  int x, y;
};

struct dimension {
		  int width, length;
};

struct cuboid {
		  struct point origin;
		  	    struct dimension base;
			    	      int height;
				      	        int volume;
};


struct cuboid newCuboid()
{
		  struct cuboid c;

		  	    c.origin.x = 0;
			    	      c.origin.y = 0;
				      	        c.base.width = 2;
								  c.base.length = 2;
								  		    c.height = 3;
										    		      c.volume = c.base.width * c.base.length * c.height;

												      		        return c;
}

void move(struct cuboid *c, int deltaX, int deltaY)
{
		  c->origin.x += deltaX;
		  	    c->origin.y += deltaY;
}

void scale(struct cuboid *c, int factor)
{
		  c->base.width *= factor;
		  	    c->base.length *= factor;
			    	      c->height *= factor;
				      	        c->volume = c->base.width * c->base.length * c->height;
}

void printCuboid(char *name, struct cuboid *c)
{
		  printf("Cuboid %s origin = (%d, %d)\n", name, c->origin.x, c->origin.y);
		  	    printf("\tBase width = %d  Base length = %d\n", c->base.width,
					    			      c->base.length);
			    	      printf("\tHeight = %d\n", c->height);
				      	        printf("\tVolume = %d\n\n", c->volume);
}
int equalSize(struct cuboid *c1, struct cuboid *c2)
{
		  int result = FALSE;

		  	    if (c1->base.width == c2->base.width) {
				    		        if (c1->base.length == c2->base.length) {
												      if (c1->height == c2->height) {
													      					              result = TRUE;
																			      						            }
												      				          }
										  }

			    	      return result;
}

int main()
{
		  struct cuboid first, second;

		  	    first = newCuboid();
			    	      second = newCuboid();

				      	        printf("Initial cuboid values:\n");
								  printCuboid("first", &first);
								  		    printCuboid("second", &second);

										    		      if (equalSize(&first, &second)) {
													      			          move(&first, +3, -6);
																	  				      scale(&second, 4);
																					      				        }

												      		        printf("\nChanged cuboid values:\n");
																		  printCuboid("first", &first);
																		  			    printCuboid("second", &second);
}
