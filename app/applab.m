function applab()
%% Control panel of experimental equipments.

    mcu = []; seedstate = false;

    function initserialmcu(~, ~)
        clear mcu;
        try
            mcu = serialport(dropdownSeedCOM.Value, 9600, "Timeout", 5);
            configureTerminator(mcu, "CR")
            disp(strcat("serialport: connected to ", dropdownSeedCOM.Value))
        catch
            disp("serialport: connection error");
        end
    end

    function buttonSeedEvent(~, ~)
        seedstate = ~seedstate;
        param.chdigout.value = {seedstate}; param.chdigout.index = {dropdownSeedChannel.Value};
        packet = jsonencode(param);
        writeline(mcu, packet)
        disp(packet)
    end

    function closeApp(~,~)
        delete(fig);
        clear mcu;
    end

    fig = uifigure(CloseRequestFcn = @closeApp);
    gridApp = uigridlayout(fig);
    gridApp.RowHeight = {'1x', '1x'}; gridApp.ColumnWidth = {'1x', '1x'};
   
    panelSeed = uipanel(gridApp, Title = 'Seeding');
    panelSeed.Layout.Row = 1;
    panelSeed.Layout.Column = 1;

    gridSeed = uigridlayout(panelSeed);
    gridSeed.RowHeight = {'1x', '1x', '1x', '1x'}; gridSeed.ColumnWidth = {'1x'};

    dropdownSeedCOM = uidropdown(gridSeed, Items = serialportlist());
    dropdownSeedCOM.Layout.Row = 1;
    dropdownSeedCOM.Layout.Column = 1;

    dropdownSeedChannel = uidropdown(gridSeed, Items = split(num2str(4:10)));
    dropdownSeedChannel.Layout.Row = 2;
    dropdownSeedChannel.Layout.Column = 1;

    buttonReinit = uibutton(gridSeed, 'Push', Text = 'Reinitialize', ButtonPushedFcn = @initserialmcu);
    buttonReinit.Layout.Row = 3;
    buttonReinit.Layout.Column = 1;

    buttonSeed = uibutton(gridSeed, 'Push', Text = 'Switch Gate', ButtonPushedFcn = @buttonSeedEvent);
    buttonSeed.Layout.Row = 4;
    buttonSeed.Layout.Column = 1;

    try
        dropdownSeedCOM.Value = 'COM8';
        dropdownSeedChannel.Value = '4';
    
        initserialmcu();
    catch 
        disp("serialport: connection error");
    end
end