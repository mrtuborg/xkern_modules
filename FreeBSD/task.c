#include <linux/init.h>
#include <linux/module.h>
MODULE_LICENSE("GPL");

static int __init task_init(void)
{
	printk(KERN_DEBUG "Hello World!");
	return 0;
}

static void __exit task_exit(void)
{

}

module_init(task_init);
module_exit(task_exit);
