class NavigationDrawerWidget extends StatelessWidget{
    final padding = EdgeInsets.symetric(horizontal: 20);

    @override
    Widget build(BuildContext context){
        final isCollapsed = false;

        return Container(
        width: isCollapsed ? MediaQuery.of(context).size.width * 0.2 : null, //finds the width of scree, gets 20%
        
        child: Drawer(
            child: Container(
                color: Colors(black),
            ),
        );
        );
    }
}