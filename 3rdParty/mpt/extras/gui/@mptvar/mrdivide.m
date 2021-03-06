function var = mrdivide(var1, var2)
%MRDIVIDE Division operator for MPTVAR objects

% Copyright is with the following author(s):
%
%(C) 2005 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%         kvasnica@control.ee.ethz.ch

% ---------------------------------------------------------------------------
% Legal note:
%          This program is free software; you can redistribute it and/or
%          modify it under the terms of the GNU General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This program is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          General Public License for more details.
% 
%          You should have received a copy of the GNU General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% ---------------------------------------------------------------------------

if isa(var1, 'mptvar') & isa(var2, 'mptvar')
    error(sprintf('%s*%s - Quadratic expressions not allowed!', char(var1), char(var2)));
end

if isa(var1, 'mptvar')
    if ~isa(var2, 'double')
        error(sprintf('Variables of class "%s" not supported!', class(var2)));
    else
        % var2 is a double
        var = var1;
        var.multiplier = var.multiplier * (1/var2);
    end
elseif isa(var2, 'mptvar')
    if ~isa(var1, 'double')
        error(sprintf('Variables of class "%s" not supported!', class(var1)));
    else
        % var1 is a double
        var = var2;
        var.multiplier = var.multiplier * (1/var1);
    end
end    
