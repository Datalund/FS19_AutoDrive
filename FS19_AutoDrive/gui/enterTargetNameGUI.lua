--
-- AutoDrive Enter Target Name GUI
-- V1.0.0.0
--
-- @author Stephan Schlosser
-- @date 08/08/2019

adEnterTargetNameGui = {};

local adEnterTargetNameGui_mt = Class(adEnterTargetNameGui, ScreenElement);

function adEnterTargetNameGui:new(target, custom_mt)
    local self = ScreenElement:new(target,adEnterTargetNameGui_mt);
    self.returnScreenName = "";
    self.textInputElement = nil;
    return self;	
end;

function adEnterTargetNameGui:onOpen()
    adEnterTargetNameGui:superClass().onOpen(self);
    FocusManager:setFocus(self.textInputElement);
    self.textInputElement:setText(""); --adEnterTargetNameGui
    --self.textInputElement:onFocusActivate();
end;

function adEnterTargetNameGui:onClickOk()
    adEnterTargetNameGui:superClass().onClickOk(self);
    local enteredName = self.textInputElement.text;

    if enteredName:len() > 1 then
        if g_currentMission.controlledVehicle ~= nil and g_currentMission.controlledVehicle.ad ~= nil then
            if AutoDrive.renameCurrentMapMarker ~= nil and AutoDrive.renameCurrentMapMarker == true then
                AutoDrive.mapMarker[g_currentMission.controlledVehicle.ad.mapMarkerSelected].name = enteredName;
                for _, mapPoint in pairs(AutoDrive.mapWayPoints) do
                    mapPoint.marker[enteredName] = mapPoint.marker[g_currentMission.controlledVehicle.ad.nameOfSelectedTarget];
                end;                
                g_currentMission.controlledVehicle.ad.nameOfSelectedTarget = enteredName;
            else
                local closest = AutoDrive:findClosestWayPoint(g_currentMission.controlledVehicle);
                if closest ~= nil and closest ~= -1 and AutoDrive.mapWayPoints[closest] ~= nil then
                    AutoDrive.mapMarkerCounter = AutoDrive.mapMarkerCounter + 1;
                    local node = createTransformGroup(enteredName);
                    setTranslation(node, AutoDrive.mapWayPoints[closest].x, AutoDrive.mapWayPoints[closest].y + 4 , AutoDrive.mapWayPoints[closest].z  );
            
                    AutoDrive.mapMarker[AutoDrive.mapMarkerCounter] = {id=closest, name= enteredName, node=node, group="All"};
                    AutoDrive:MarkChanged();
                    

                    if g_server ~= nil then
                        AutoDrive:broadCastUpdateToClients();
                    else
                        AutoDriveCreateMapMarkerEvent:sendEvent(g_currentMission.controlledVehicle, closest, enteredName);
                    end;
                end;
            end;
            
            AutoDrive:notifyDestinationListeners();  
            AutoDrive.Hud.lastUIScale = 0;          
        end;       
    end;    
    
    self:onClickBack();
end;

function adEnterTargetNameGui:onClickResetButton()
    self.textInputElement:setText("");
    if g_currentMission.controlledVehicle ~= nil and g_currentMission.controlledVehicle.ad ~= nil then
        if AutoDrive.renameCurrentMapMarker ~= nil and AutoDrive.renameCurrentMapMarker == true then
            self.textInputElement:setText("" .. AutoDrive.mapMarker[g_currentMission.controlledVehicle.ad.mapMarkerSelected].name);
        end;
    end;
end;

function adEnterTargetNameGui:onClose()
    adEnterTargetNameGui:superClass().onClose(self);
end;

function adEnterTargetNameGui:onClickBack()
    adEnterTargetNameGui:superClass().onClickBack(self);
end;

function adEnterTargetNameGui:onCreateInputElement(element)
    self.textInputElement = element;   
    element.text = "";
end;

function adEnterTargetNameGui:onEnterPressed()    
    if AutoDrive.openTargetGUINextFrame == nil or AutoDrive.openTargetGUINextFrame <= 0 then
        self:onClickOk();
    end;
end;

function adEnterTargetNameGui:onEscPressed()
    if AutoDrive.openTargetGUINextFrame == nil or AutoDrive.openTargetGUINextFrame <= 0 then
        self:onClose();
    end;
end;