% =========================================================================
% By: Carlos Daniel Zamora Pérez, Mario Oscar Ordaz Oliver
% mail: l22200629@pachuca.tecnm.mx
% SCRIPT: MiZBus.m
% Architecture: Procedural Script with Local Functions and AppData

% =========================================================================
clear vars; close all; clc;
% 1. MAIN FIGURE CREATION
fig = uifigure('Name', 'C-DZP/Z-Bus Analyzer - Electric Power Systems', ...
               'Position', [100, 100, 1200, 750]);
% 2. INITIALIZATION OF STATE VARIABLES (App Memory)
% setappdata is used to avoid global variable conflicts
setappdata(fig, 'branchData', []); % [From_Node, To_Node, R, X]
% 3. GRAPHICAL USER INTERFACE (GUI) CONSTRUCTION
gl = uigridlayout(fig, [2, 3]);
gl.RowHeight = {150, '1x'};
gl.ColumnWidth = {300, '1x', 300};
ui = struct(); % Structure to store visual components
% --- DATA INPUT PANEL ---
pnlInput = uipanel(gl, 'Title', 'Add Impedances to System', 'FontWeight', 'bold');
pnlInput.Layout.Row = 1; pnlInput.Layout.Column = 1;
uilabel(pnlInput, 'Position', [10, 100, 80, 22], 'Text', 'From Bus:');
ui.ddFrom = uieditfield(pnlInput, 'numeric', 'Position', [90, 100, 60, 22], 'Value', 0);
uilabel(pnlInput, 'Position', [160, 100, 80, 22], 'Text', 'To Bus:');
ui.ddTo = uieditfield(pnlInput, 'numeric', 'Position', [220, 100, 60, 22], 'Value', 1);
uilabel(pnlInput, 'Position', [10, 60, 80, 22], 'Text', 'R (p.u.):');
ui.numR = uieditfield(pnlInput, 'numeric', 'Position', [90, 60, 60, 22], 'Value', 0);
uilabel(pnlInput, 'Position', [160, 60, 80, 22], 'Text', 'X (p.u.):');
ui.numX = uieditfield(pnlInput, 'numeric', 'Position', [220, 60, 60, 22], 'Value', 0.1);
ui.btnAnadir = uibutton(pnlInput, 'push', 'Position', [10, 15, 270, 30], ...
                     'Text', 'Add Impedance to Network');
                 
% --- MAIN CONTROLS PANEL ---
pnlControl = uipanel(gl, 'Title', 'Execution Control', 'FontWeight', 'bold');
pnlControl.Layout.Row = 1; pnlControl.Layout.Column = 2;
ui.btnCalcular = uibutton(pnlControl, 'push', 'Position', [50, 45, 200, 40], ...
                       'Text', 'CALCULATE Z-BUS MATRIX', ...
                       'BackgroundColor', [0.2 0.6 0.3], 'FontColor', 'white', 'FontWeight', 'bold');
                   
ui.btnLimpiar = uibutton(pnlControl, 'push', 'Position', [270, 45, 100, 40], ...
                       'Text', 'Clear All', ...
                       'BackgroundColor', [0.8 0.2 0.2], 'FontColor', 'white');
                   
uilabel(pnlControl, 'Position', [50, 10, 400, 22], 'Text', '* Note: Node 0 is always considered the Reference Node.');
% --- NETWORK VISUALIZATION AREA ---
ui.axNet = uiaxes(gl);
ui.axNet.Layout.Row = 2; ui.axNet.Layout.Column = [1, 2];
title(ui.axNet, 'Power System Topology');
ui.axNet.XTick = []; ui.axNet.YTick = []; 
% --- LOG AND RESULTS PANEL ---
pnlLog = uipanel(gl, 'Title', 'Case Log and Resolution', 'FontWeight', 'bold');
pnlLog.Layout.Row = [1, 2]; pnlLog.Layout.Column = 3;
ui.txtLog = uitextarea(pnlLog, 'Position', [10, 300, 280, 400], 'Editable', 'off');
uilabel(pnlLog, 'Position', [10, 270, 200, 22], 'Text', 'Final Z-bus Matrix (Complex):', 'FontWeight', 'bold');
ui.tblZ = uitable(pnlLog, 'Position', [10, 10, 280, 250]);
% Save components in figure memory
setappdata(fig, 'ui', ui);
% 4. CALLBACK ASSIGNMENT (Button Events)
ui.btnAnadir.ButtonPushedFcn = @(src, event) addBranch_cb(fig);
ui.btnCalcular.ButtonPushedFcn = @(src, event) solveZBus_cb(fig);
ui.btnLimpiar.ButtonPushedFcn = @(src, event) clearAll_cb(fig);
% =========================================================================
% 5. LOCAL FUNCTIONS (PROGRAM LOGIC)
% =========================================================================
function addBranch_cb(fig)
    ui = getappdata(fig, 'ui');
    branchData = getappdata(fig, 'branchData');
    
    n_from = round(ui.ddFrom.Value);
    n_to = round(ui.ddTo.Value);
    R = ui.numR.Value;
    X = ui.numX.Value;
    
    % Validations
    if n_from < 0 || n_to < 0
        uialert(fig, 'Nodes cannot be negative.', 'Error'); return;
    end
    if n_from == n_to
        uialert(fig, 'An impedance cannot connect to the same node.', 'Error'); return;
    end
    if R == 0 && X == 0
        uialert(fig, 'Impedance cannot be zero.', 'Error'); return;
    end
    
    % Add data
    branchData = [branchData; n_from, n_to, R, X];
    setappdata(fig, 'branchData', branchData); % Save changes
    
    logMsg(ui, sprintf('Added Z=%.4f + j%.4f between nodes %d and %d', R, X, n_from, n_to));
    updateGraph_cb(fig, ui, branchData);
end
function clearAll_cb(fig)
    ui = getappdata(fig, 'ui');
    setappdata(fig, 'branchData', []);
    cla(ui.axNet);
    ui.txtLog.Value = '';
    ui.tblZ.Data = [];
    logMsg(ui, 'System reset.');
end
function logMsg(ui, msg)
    currentLog = ui.txtLog.Value;
    if ischar(currentLog)
        currentLog = {currentLog};
    end
    ui.txtLog.Value = [currentLog; {msg}];
    scroll(ui.txtLog, 'bottom');
end
function updateGraph_cb(fig, ui, branchData)
    if isempty(branchData)
        cla(ui.axNet); return;
    end
    
    s = branchData(:, 1);
    t = branchData(:, 2);
    
    s_str = cellstr(num2str(s));
    t_str = cellstr(num2str(t));
    
    G = graph(s_str, t_str);
    
    h = plot(ui.axNet, G, 'Layout', 'force', 'NodeLabel', G.Nodes.Name, ...
        'MarkerSize', 8, 'LineWidth', 2);
    
    idxRef = find(strcmp(G.Nodes.Name, '0'));
    if ~isempty(idxRef)
        highlight(h, idxRef, 'NodeColor', 'r', 'Marker', 's', 'MarkerSize', 12);
    end
end
function solveZBus_cb(fig)
    ui = getappdata(fig, 'ui');
    branchData = getappdata(fig, 'branchData');
    
    if isempty(branchData)
        uialert(fig, 'There are no impedances in the system.', 'Error'); return;
    end
    
    logMsg(ui, '--------------------------------');
    logMsg(ui, 'STARTING Z-BUS CONSTRUCTION');
    logMsg(ui, '--------------------------------');
    
    all_nodes = unique([branchData(:,1); branchData(:,2)]);
    all_nodes(all_nodes == 0) = []; 
    N = max(all_nodes); 
    
    if isempty(N)
        logMsg(ui, 'Error: There are no valid buses beyond the reference.');
        return;
    end
    
    Z = zeros(0, 0);
    nodos_incluidos = []; 
    ramas_pendientes = branchData;
    paso = 1;
    
    while ~isempty(ramas_pendientes)
        rama_aplicada = false;
        
        for i = 1:size(ramas_pendientes, 1)
            nodoA = ramas_pendientes(i, 1);
            nodoB = ramas_pendientes(i, 2);
            Zb = ramas_pendientes(i, 3) + 1i * ramas_pendientes(i, 4);
            
            A_en_red = ismember(nodoA, nodos_incluidos) || (nodoA == 0);
            B_en_red = ismember(nodoB, nodos_incluidos) || (nodoB == 0);
            
            % CASE 1
            if (nodoA == 0 && ~ismember(nodoB, nodos_incluidos)) || ...
               (nodoB == 0 && ~ismember(nodoA, nodos_incluidos))
                nuevo_nodo = max(nodoA, nodoB);
                logMsg(ui, sprintf('Step %d: Impedance between Ref (0) and Bus %d.', paso, nuevo_nodo));
                logMsg(ui, sprintf(' -> APPLYING CASE 1 (Z = %.4f+j%.4f)', real(Zb), imag(Zb)));
                
                Z(nuevo_nodo, nuevo_nodo) = Zb;
                nodos_incluidos = [nodos_incluidos, nuevo_nodo];
                rama_aplicada = true;
                
            % CASE 2
            elseif A_en_red && ~B_en_red || ~A_en_red && B_en_red
                if A_en_red
                    k = nodoA; nuevo_nodo = nodoB;
                else
                    k = nodoB; nuevo_nodo = nodoA;
                end
                logMsg(ui, sprintf('Step %d: Impedance from Existing Bus %d to New Bus %d.', paso, k, nuevo_nodo));
                logMsg(ui, sprintf(' -> APPLYING CASE 2 (Z = %.4f+j%.4f)', real(Zb), imag(Zb)));
                
                Z(:, nuevo_nodo) = Z(:, k);
                Z(nuevo_nodo, :) = Z(k, :);
                Z(nuevo_nodo, nuevo_nodo) = Z(k, k) + Zb;
                nodos_incluidos = [nodos_incluidos, nuevo_nodo];
                rama_aplicada = true;
                
            % CASE 3 or 4
            elseif A_en_red && B_en_red
                logMsg(ui, sprintf('Step %d: Closed link between Bus %d and Bus %d.', paso, nodoA, nodoB));
                Z_temp_col = zeros(size(Z, 1), 1);
                
                if nodoA == 0 % Case 3
                    logMsg(ui, ' -> APPLYING CASE 3 (Kron Reduction to Ref)');
                    k = nodoB; Z_temp_col = -Z(:, k); Zth = Z(k, k);
                elseif nodoB == 0 % Case 3
                    logMsg(ui, ' -> APPLYING CASE 3 (Kron Reduction to Ref)');
                    k = nodoA; Z_temp_col = -Z(:, k); Zth = Z(k, k);
                else % Case 4
                    logMsg(ui, ' -> APPLYING CASE 4 (Kron Reduction between buses)');
                    j = nodoA; k = nodoB;
                    Z_temp_col = Z(:, j) - Z(:, k);
                    Zth = Z(j, j) + Z(k, k) - 2 * Z(j, k);
                end
                
                Z_pp = Zth + Zb;
                Z = Z - (Z_temp_col * Z_temp_col') / Z_pp;
                rama_aplicada = true;
            end
            
            if rama_aplicada
                ramas_pendientes(i, :) = [];
                paso = paso + 1;
                break; 
            end
        end
        
        if ~rama_aplicada && ~isempty(ramas_pendientes)
            logMsg(ui, 'WARNING: An isolated subnetwork (island) with no connection to the reference has been detected.');
            return;
        end
    end
    
    logMsg(ui, '--------------------------------');
    logMsg(ui, 'CALCULATION COMPLETED SUCCESSFULLY');
    logMsg(ui, '--------------------------------');
    
    [filas, cols] = size(Z);
    Z_str = cell(filas, cols);
    for r = 1:filas
        for c = 1:cols
            if imag(Z(r,c)) >= 0
                Z_str{r,c} = sprintf('%.4f + j%.4f', real(Z(r,c)), imag(Z(r,c)));
            else
                Z_str{r,c} = sprintf('%.4f - j%.4f', real(Z(r,c)), abs(imag(Z(r,c))));
            end
        end
    end
    
    ui.tblZ.Data = Z_str;
    nombres_barras = cellstr(strcat('Bus ', num2str((1:filas)')));
    ui.tblZ.RowName = nombres_barras;
    ui.tblZ.ColumnName = nombres_barras;
end