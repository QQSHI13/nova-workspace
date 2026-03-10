// This is a C# comment - it's just notes for humans, the computer ignores it

// These are "using" statements - they let us use code from other libraries
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;

// This is the "namespace" - it's like a folder for our code
namespace QuickNotesPlugin;

// This is our main plugin class! It implements the ICommandPalettePlugin interface
// (which is required for PowerToys Command Palette extensions)
public class SimpleQuickNotesPlugin : ICommandPalettePlugin
{
    // These are "properties" - they give PowerToys info about our plugin
    public string Id => "QuickNotes";           // Unique ID for our plugin
    public string Name => "Quick Notes";        // Name shown in Command Palette
    public string Description => "Create notes in Notepad";  // Short description
    public Image Icon => SystemIcons.Application.ToBitmap();  // Icon (use default Windows app icon)

    // This is the main method! PowerToys calls this when the user types in the Command Palette
    // It returns a list of results to show
    public IEnumerable<ICommandPaletteResult> GetResults(string query)
    {
        // Create an empty list to hold our results
        List<ICommandPaletteResult> results = new List<ICommandPaletteResult>();

        // Make the query lowercase for easier matching (so "Open NOTEPAD" works too)
        string lowerQuery = query.ToLower();

        // --- COMMAND 1: Open Notepad ---
        // If the query is empty OR contains "notepad", show this result
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("notepad"))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Open Notepad",          // Big text shown
                Subtitle = "Create a new note",  // Smaller description
                Icon = this.Icon,                 // Use our plugin's icon
                // This is what happens when the user clicks the result!
                Action = () =>
                {
                    // 1. Get the user's home folder (like C:\Users\QQ\)
                    string homeFolder = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                    
                    // 2. Make a "notes" folder inside it (if it doesn't exist)
                    string notesFolder = Path.Combine(homeFolder, "notes");
                    Directory.CreateDirectory(notesFolder);
                    
                    // 3. Make a filename with the current date and time (like 2026-03-09_16-46-00.txt)
                    string timestamp = DateTime.Now.ToString("yyyy-MM-dd_HH-mm-ss");
                    string filename = timestamp + ".txt";
                    string fullPath = Path.Combine(notesFolder, filename);
                    
                    // 4. Create the empty file
                    File.Create(fullPath).Close();
                    
                    // 5. Open it in Notepad!
                    Process.Start("notepad.exe", fullPath);
                }
            });
        }

        // --- COMMAND 2: Settings ---
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("settings"))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Settings",
                Subtitle = "Coming soon!",
                Icon = this.Icon,
                Action = () =>
                {
                    // Show a simple message box for now
                    MessageBox.Show("Settings are coming soon!", "Quick Notes");
                }
            });
        }

        // --- COMMAND 3: Help ---
        if (string.IsNullOrEmpty(query) || lowerQuery.Contains("help"))
        {
            results.Add(new CommandPaletteResult
            {
                Title = "Help",
                Subtitle = "How to use Quick Notes",
                Icon = this.Icon,
                Action = () =>
                {
                    // Show a help message
                    string helpText = "Quick Notes Help:\n\n" +
                                      "- Type 'Open Notepad' to create a new note\n" +
                                      "- Notes are saved in your 'notes' folder\n" +
                                      "- Files are named with the date and time";
                    MessageBox.Show(helpText, "Quick Notes Help");
                }
            });
        }

        // Return all the results we added!
        return results;
    }
}
