import UIKit
import Eureka
import ViewRow
import ColorPickerRow

class CardOptionsController: FormViewController {
    var nameCard: NameCard!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ ColorPickerRow(tagColor) {
            row in
            row.title = NSLocalizedString("Background Color", comment: "")
            row.value = .white
            }
            .cellSetup {
                cell, row in
                let palette1 = ColorPalette(name: NSLocalizedString("Reds", comment: ""), palette: [
                    ColorSpec(hex: "#ffebeb", name: ""),
                    ColorSpec(hex: "#fed1d1", name: ""),
                    ColorSpec(hex: "#fe9e9e", name: ""),
                    ColorSpec(hex: "#e4bcbc", name: ""),
                    ColorSpec(hex: "#cba7a7", name: "")
                    ])
                let palette2 = ColorPalette(name: NSLocalizedString("Yellows", comment: ""), palette: [
                    ColorSpec(hex: "#fbffeb", name: ""),
                    ColorSpec(hex: "#fafed1", name: ""),
                    ColorSpec(hex: "#f5fe9e", name: ""),
                    ColorSpec(hex: "#e1e4bc", name: ""),
                    ColorSpec(hex: "#c8cba7", name: "")
                    ])
                let palette3 = ColorPalette(name: NSLocalizedString("Greens", comment: ""), palette: [
                    ColorSpec(hex: "#ebfff0", name: ""),
                    ColorSpec(hex: "#d1fed3", name: ""),
                    ColorSpec(hex: "#9efea3", name: ""),
                    ColorSpec(hex: "#bce4be", name: ""),
                    ColorSpec(hex: "#a7cba9", name: "")
                    ])
                let palette4 = ColorPalette(name: NSLocalizedString("Blues", comment: ""), palette: [
                    ColorSpec(hex: "#ebf9ff", name: ""),
                    ColorSpec(hex: "#d1fdfe", name: ""),
                    ColorSpec(hex: "#9efdfe", name: ""),
                    ColorSpec(hex: "#bce4e4", name: ""),
                    ColorSpec(hex: "#a7cacb", name: "")
                    ])
                let palette5 = ColorPalette(name: NSLocalizedString("Purples", comment: ""), palette: [
                    ColorSpec(hex: "#faebff", name: ""),
                    ColorSpec(hex: "#ead1fe", name: ""),
                    ColorSpec(hex: "#d49efe", name: ""),
                    ColorSpec(hex: "#d2bce4", name: ""),
                    ColorSpec(hex: "#bba7cb", name: "")
                    ])
                let palette6 = ColorPalette(name:  NSLocalizedString("Grayscale", comment: ""), palette: [
                    ColorSpec(hex: "#ffffff", name: ""),
                    ColorSpec(hex: "#f3f3f3", name: ""),
                    ColorSpec(hex: "#dadada", name: ""),
                    ColorSpec(hex: "#c0c0c0", name: "")
                    ])
                cell.palettes = [palette1, palette2, palette3, palette4, palette5, palette6]
        }
            .onChange({ [weak self] (row) in
                self?.nameCard.color = (row.value ?? .white).toInt()
                (self?.form.rowBy(tag: tagPreview) as? ViewRow<UIView>)?.cell.view?.backgroundColor = row.value ?? .white
            })
        
        form +++ PushRow<Group>(tagAddToGroup) {
            row in
            let noneGroup = Group()
            noneGroup.name = "None"
            let newGroup = Group()
            newGroup.name = "New Group"
            row.options = [noneGroup] + Array(RealmWrapper.shared.groups) + [newGroup]
            row.title = "Add to Group"
            row.value = noneGroup
        }
        
        <<< TextRow(tagNewGroupName) {
            row in
            row.title = "Name"
            row.hidden = Condition.function([tagAddToGroup], { (form) -> Bool in
                let addToGroupRow: RowOf<Group> = form.rowBy(tag: tagAddToGroup)!
                return addToGroupRow.value?.name != "New Group"
            })
        }
        
        form +++ Section("preview")
        
        <<< ViewRow<UIView>(tagPreview) {
            row in
            
            }.cellSetup({ [weak self] (cell, row) in
                cell.view = self?.nameCard.createCardView(withWidth: cell.width - cell.viewLeftMargin - cell.viewRightMargin)
                cell.backgroundColor = .black
            })
    }
    
    @IBAction func done() {
        let values = form.values(includeHidden: false)
        if let group = values[tagAddToGroup] as? Group {
            if group.name != "None" {
                if group.name == "New Group" {
                    let newGroup = Group()
                    newGroup.name = values[tagNewGroupName] as? String ?? ""
                    if !newGroup.validateAndShowAlert() {
                        return
                    }
                } else {
                }
            } else {
            }
        }
        performSegue(withIdentifier: "unwindToCardList", sender: nil)
    }
}
